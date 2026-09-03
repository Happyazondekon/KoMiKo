import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/models/user_model.dart';
import 'package:komiko/screens/pro_upgrade_screen.dart';
import 'package:komiko/services/content_moderation_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/purchase_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:komiko/widgets/bubble_button.dart';
import 'package:komiko/widgets/joke_enhance_sheet.dart';
import 'package:komiko/services/feature_quota_service.dart';
import 'package:provider/provider.dart';

class ProposeJokeScreen extends StatefulWidget {
  const ProposeJokeScreen({super.key});

  @override
  State<ProposeJokeScreen> createState() => _ProposeJokeScreenState();
}

class _ProposeJokeScreenState extends State<ProposeJokeScreen> {
  final _contentController = TextEditingController();
  final _punchlineController = TextEditingController();
  // Stores the canonical Firestore category key (not the localized label)
  String _selectedCategory = JokeCategories.general;
  bool _isLoading = false;
  bool _isFeatured = false;

  // Image Pro
  File? _selectedImageFile;
  String? _imageBase64;
  bool _isCompressingImage = false;

  final _moderation = ContentModerationService.instance;
  final _imagePicker = ImagePicker();

  // Limite max de la taille base64 (~750 ko brut → ~1 Mo encodé)
  static const int _maxImageBytes = 750 * 1024;

  // Quotas 5 utilisations gratuites pour les membres standards
  int _remainingPhotos = FeatureQuotaService.maxFreeUses;
  int _remainingAssistant = FeatureQuotaService.maxFreeUses;

  @override
  void initState() {
    super.initState();
    _loadQuotas();
  }

  Future<void> _loadQuotas() async {
    final user = Provider.of<UserService>(context, listen: false).currentUser;
    final photos = await FeatureQuotaService.instance.getRemainingPhotoUses(user?.uid);
    final assistant = await FeatureQuotaService.instance.getRemainingAssistantUses(user?.uid);
    if (mounted) {
      setState(() {
        _remainingPhotos = photos;
        _remainingAssistant = assistant;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _punchlineController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCompressImage({
    required bool isPro,
    required UserModel? user,
  }) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70, // Compression initiale
      );
      if (picked == null) return;

      setState(() => _isCompressingImage = true);

      final file = File(picked.path);
      final bytes = await file.readAsBytes();

      File? finalFile;
      String? finalBase64;

      // Vérification taille
      if (bytes.length > _maxImageBytes) {
        // Recompresser avec qualité réduite
        final recompressed = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 600,
          maxHeight: 600,
          imageQuality: 50,
        );
        if (recompressed == null) {
          setState(() => _isCompressingImage = false);
          return;
        }
        final recompressedBytes = await File(recompressed.path).readAsBytes();
        if (recompressedBytes.length > _maxImageBytes) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.imageTooHeavy,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          setState(() => _isCompressingImage = false);
          return;
        }
        finalFile = File(recompressed.path);
        finalBase64 = base64Encode(recompressedBytes);
      } else {
        finalFile = file;
        finalBase64 = base64Encode(bytes);
      }

      setState(() {
        _selectedImageFile = finalFile;
        _imageBase64 = finalBase64;
        _isCompressingImage = false;
      });

      // Si l'utilisateur n'est pas Pro, décompter un essai gratuit
      if (!isPro) {
        final remaining = await FeatureQuotaService.instance.consumePhotoUse(user?.uid);
        if (mounted) {
          setState(() => _remainingPhotos = remaining);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.freeUsesLeft(remaining),
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isCompressingImage = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingImage,
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _imageBase64 = null;
    });
  }

  Future<void> _submitJoke() async {
    final l10n = AppLocalizations.of(context)!;
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.enterJokeContent)));
      return;
    }

    // Vérification de restriction
    final user = context.read<UserService>().currentUser;
    if (user == null) return;

    if (user.isRestricted || user.isBanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.accountRestrictedMsg,
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final joke = Joke(
        id: '',
        contentFr: _moderation.censorText(content),
        punchlineFr: _punchlineController.text.trim().isEmpty
            ? null
            : _moderation.censorText(_punchlineController.text.trim()),
        category: _selectedCategory,
        authorName: user.username ?? l10n.anonymous,
        authorId: user.uid,
        authorAvatarUrl: user.avatarUrl,
        isAuthorVerified: user.isVerified || user.hasActivePro,
        createdAt: DateTime.now(),
        imageBase64: _imageBase64,
        isFeatured: _isFeatured,
      );

      await JokeService().addJoke(joke);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.jokePublished,
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final purchaseService = context.watch<PurchaseService>();
    final currentUser = context.watch<UserService>().currentUser;
    final isPro = purchaseService.isPro ||
        (currentUser?.hasActivePro ?? false) ||
        (currentUser?.effectiveIsVerified ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proposeJoke,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Bannière Pro si non-Pro ──────────────────────────────
            if (!isPro) _ProUpsellBanner(isDark: isDark),
            if (!isPro) const SizedBox(height: 16),

            // ── Catégorie ─────────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.category,
                border: const OutlineInputBorder(),
              ),
              items: JokeCategories.all
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(JokeCategories.getLocalizedName(key, l10n),
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),

            // ── Contenu avec icône photo intégrée ─────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    minLines: 3,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: l10n.jokeContent,
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                  // Si une image est attachée : miniature élégante à l'intérieur
                  if (_isCompressingImage)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (_selectedImageFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImageFile!,
                                height: 90,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Barre d'action inférieure : Photo & Assistant Komiko avec 5 essais gratuits
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 12, bottom: 6),
                    child: Row(
                      children: [
                        // ── Bouton Photo ────────────────────────────────────
                        IconButton(
                          tooltip: l10n.addPhoto,
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: _selectedImageFile != null
                                    ? AppColors.primary
                                    : (isDark ? Colors.white70 : Colors.black54),
                                size: 24,
                              ),
                              if (!isPro)
                                Positioned(
                                  right: -6,
                                  top: -3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _remainingPhotos > 0 ? AppColors.primary : Colors.amber,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _remainingPhotos > 0 ? '$_remainingPhotos' : 'Pro',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            if (isPro || _remainingPhotos > 0) {
                              _pickAndCompressImage(isPro: isPro, user: currentUser);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.freeQuotaExhaustedPhoto,
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'Pro',
                                    textColor: Colors.white,
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProUpgradeScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProUpgradeScreen(),
                                ),
                              );
                            }
                          },
                        ),

                        // ── Bouton Assistant Komiko (Shine) ─────────────────
                        IconButton(
                          tooltip: l10n.enhanceJokeAi,
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [AppColors.primary, Color(0xFFFFD700)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              if (!isPro)
                                Positioned(
                                  right: -6,
                                  top: -3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _remainingAssistant > 0 ? AppColors.primary : Colors.amber,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _remainingAssistant > 0 ? '$_remainingAssistant' : 'Pro',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            if (isPro || _remainingAssistant > 0) {
                              final text = _contentController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.enhanceEmptyWarning,
                                      style: GoogleFonts.poppins(fontSize: 13),
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              JokeEnhanceSheet.show(
                                context,
                                content: text,
                                punchline: _punchlineController.text.trim(),
                                onApply: ({required content, required punchline}) async {
                                  setState(() {
                                    _contentController.text = content;
                                    if (punchline.isNotEmpty) {
                                      _punchlineController.text = punchline;
                                    }
                                  });

                                  // Consommer un essai de l'Assistant si non Pro
                                  if (!isPro) {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final currentL10n = l10n;
                                    final remaining = await FeatureQuotaService.instance.consumeAssistantUse(currentUser?.uid);
                                    if (mounted) {
                                      setState(() => _remainingAssistant = remaining);
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            currentL10n.freeUsesLeft(remaining),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: AppColors.primary,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.freeQuotaExhaustedAssistant,
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'Pro',
                                    textColor: Colors.white,
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProUpgradeScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProUpgradeScreen(),
                                ),
                              );
                            }
                          },
                        ),

                        if (!isPro) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProUpgradeScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (_remainingPhotos > 0 || _remainingAssistant > 0)
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: (_remainingPhotos > 0 || _remainingAssistant > 0)
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : Colors.amber.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                (_remainingPhotos > 0 || _remainingAssistant > 0)
                                    ? l10n.freeBadge
                                    : 'Pro',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: (_remainingPhotos > 0 || _remainingAssistant > 0)
                                      ? AppColors.primary
                                      : Colors.amber,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Punchline ─────────────────────────────────────────────
            TextField(
              controller: _punchlineController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                labelText: l10n.punchline,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Toggle "Mettre en vedette" (Pro seulement) ────────────
            if (isPro) ...[
              _FeaturedToggle(
                isDark: isDark,
                isFeatured: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              const SizedBox(height: 20),
            ],

            // ── Bouton publier ─────────────────────────────────────────
            BubbleButton(
              onTap: _isLoading ? null : _submitJoke,
              label: l10n.publish,
              fullWidth: true,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _ProUpsellBanner extends StatelessWidget {
  final bool isDark;
  const _ProUpsellBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProUpgradeScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              const Color(0xFFFFD700).withValues(alpha: 0.1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proUpgradeBannerTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    l10n.proUpgradeBannerSubtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}



class _FeaturedToggle extends StatelessWidget {
  final bool isDark;
  final bool isFeatured;
  final ValueChanged<bool> onChanged;

  const _FeaturedToggle({
    required this.isDark,
    required this.isFeatured,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFeatured
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured
              ? AppColors.primary.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.boostInFeed,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  l10n.boostInFeedDesc,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isFeatured,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
