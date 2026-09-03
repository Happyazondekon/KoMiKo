import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/services/groq_ai_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/widgets/bubble_button.dart';

/// Modal d'assistance humoristique IA pour reformuler et sublimer les blagues.
class JokeEnhanceSheet extends StatefulWidget {
  final String content;
  final String? punchline;
  final Function({required String content, required String punchline}) onApply;

  const JokeEnhanceSheet({
    super.key,
    required this.content,
    this.punchline,
    required this.onApply,
  });

  /// Ouvre la bottom sheet de manière fluide
  static Future<void> show(
    BuildContext context, {
    required String content,
    String? punchline,
    required Function({required String content, required String punchline}) onApply,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => JokeEnhanceSheet(
        content: content,
        punchline: punchline,
        onApply: onApply,
      ),
    );
  }

  @override
  State<JokeEnhanceSheet> createState() => _JokeEnhanceSheetState();
}

class _JokeEnhanceSheetState extends State<JokeEnhanceSheet> {
  bool _isLoading = false;
  Map<String, String>? _enhancedResult;
  String? _errorMessage;

  Future<void> _runEnhance(String tone) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    HapticFeedback.selectionClick();

    final langCode = Localizations.localeOf(context).languageCode;
    final isFr = langCode == 'fr';
    final result = await GroqAiService.instance.enhanceJoke(
      content: widget.content,
      currentPunchline: widget.punchline,
      tone: tone,
      langCode: langCode,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _enhancedResult = result;
        if (result == null) {
          _errorMessage = isFr
              ? "L'Assistant Komiko est momentanément indisponible. Vérifiez votre connexion internet ou réessayez dans un instant."
              : "Komiko Assistant is temporarily unavailable. Please check your internet connection or try again shortly.";
        }
      });
      if (result != null) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final options = [
      _EnhanceOption(
        id: 'funnier',
        icon: Icons.sentiment_very_satisfied_rounded,
        title: l10n.enhanceOptionFunnier,
        subtitle: l10n.enhanceOptionFunnierDesc,
        accentColor: AppColors.primary,
      ),
      _EnhanceOption(
        id: 'punchy',
        icon: Icons.bolt_rounded,
        title: l10n.enhanceOptionPunchy,
        subtitle: l10n.enhanceOptionPunchyDesc,
        accentColor: const Color(0xFFFF9100),
      ),
      _EnhanceOption(
        id: 'punchline',
        icon: Icons.crisis_alert_rounded,
        title: l10n.enhanceOptionPunchline,
        subtitle: l10n.enhanceOptionPunchlineDesc,
        accentColor: AppColors.pink,
      ),
      _EnhanceOption(
        id: 'clean',
        icon: Icons.spellcheck_rounded,
        title: l10n.enhanceOptionClean,
        subtitle: l10n.enhanceOptionCleanDesc,
        accentColor: AppColors.blue,
      ),
      _EnhanceOption(
        id: 'crazy',
        icon: Icons.casino_rounded,
        title: l10n.enhanceOptionCrazy,
        subtitle: l10n.enhanceOptionCrazyDesc,
        accentColor: const Color(0xFF00E676),
      ),
      _EnhanceOption(
        id: 'dark',
        icon: Icons.nightlight_round,
        title: l10n.enhanceOptionDark,
        subtitle: l10n.enhanceOptionDarkDesc,
        accentColor: const Color(0xFF9C27B0),
      ),
    ];

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre indicateur de glissement
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // En-tête : Titre & Assistant IA
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFFD700)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.enhanceJokeAiTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      l10n.enhanceJokeAiSubtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── État 1 : Chargement de l'IA ──────────────────────────────
          if (_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.aiGeneratingProposal,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ]

          // ── État 2 : Proposition générée ──────────────────────────────
          else if (_enhancedResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l10n.enhancedVersion,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _enhancedResult!['content'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if ((_enhancedResult!['punchline'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _enhancedResult!['punchline']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            BubbleButton(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onApply(
                  content: _enhancedResult!['content'] ?? widget.content,
                  punchline: _enhancedResult!['punchline'] ?? (widget.punchline ?? ''),
                );
                Navigator.of(context).pop();
              },
              label: l10n.applyAiSuggestion,
              fullWidth: true,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() => _enhancedResult = null);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                l10n.tryAnotherStyle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]

          // ── État 3 : Sélection du style ──────────────────────────────
          else ...[
            if (_errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 440),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final opt = options[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _runEnhance(opt.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: opt.accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(opt.icon,
                                  color: opt.accentColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt.title,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    opt.subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EnhanceOption {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  _EnhanceOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
