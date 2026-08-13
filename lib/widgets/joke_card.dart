import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/screens/joke_detail_screen.dart';
import 'package:komiko/screens/user_profile_screen.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/notification_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class JokeCard extends StatefulWidget {
  final Joke joke;

  const JokeCard({super.key, required this.joke});

  @override
  State<JokeCard> createState() => _JokeCardState();
}

class _JokeCardState extends State<JokeCard> {
  final _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareJokeAsImage() async {
    setState(() => _isSharing = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      final langCode = Localizations.localeOf(context).languageCode;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final theme = Theme.of(context);

      final content = widget.joke.localizedContent(langCode);
      final punchline = widget.joke.localizedPunchline(langCode);

      final image = await _screenshotController.captureFromWidget(
        Material(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: const Size(400, 3000), // Sufficiently tall for long jokes
            ),
            child: Theme(
              data: theme,
              child: JokeShareTemplate(
                joke: widget.joke,
                l10n: l10n,
                langCode: langCode,
                isDark: isDark,
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/komiko_joke_${widget.joke.id}.png').create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: l10n.shareText(content, punchline ?? ''),
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final joke = widget.joke;
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final userId = context.read<AuthService>().currentUser?.uid ?? '';
    final isLiked = joke.likedBy.contains(userId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = joke.localizedContent(langCode);
    final punchline = joke.localizedPunchline(langCode);
    final categoryLabel = JokeCategories.getLocalizedName(joke.category, l10n);
    final ago = timeAgo(joke.createdAt, langCode);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JokeDetailScreen(joke: joke)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(color: AppColors.darkBorder, width: 1)
              : Border.all(color: AppColors.lightBorder, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Author row ──────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UserProfileScreen(userId: joke.authorId)),
                ),
                child: Row(
                  children: [
                    AuthorAvatar(
                      url: joke.authorAvatarUrl,
                      name: joke.authorName,
                      radius: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  joke.authorName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (joke.isAuthorVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    color: AppColors.primary, size: 14),
                              ],
                            ],
                          ),
                          Text(
                            '$ago • $categoryLabel',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Share icon
                    _isSharing
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.share_outlined,
                              size: 18,
                              color:
                                  isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                            onPressed: _shareJokeAsImage,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // ── Joke content ────────────────────────────────────────
              ExpandableText(
                text: content,
                maxLines: 4,
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              if (punchline != null && punchline.isNotEmpty) ...
                [
                  const SizedBox(height: 8),
                  ExpandableText(
                    text: punchline,
                    maxLines: 2,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              const SizedBox(height: 14),
              // ── Actions ───────────────────────────────────────────────
              Row(
                children: [
                  _StatChip(
                    icon: isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    count: joke.likesCount,
                    color: AppColors.pink,
                    onTap: userId.isNotEmpty
                        ? () async {
                            final wasLiked = joke.likedBy.contains(userId);
                            await JokeService().likeJoke(joke.id, userId);
                            if (!wasLiked && joke.authorId != userId) {
                              if (context.mounted) {
                                final user = context.read<UserService>().currentUser;
                                NotificationService.createLikeNotification(
                                  recipientId: joke.authorId,
                                  actorId: userId,
                                  actorName: user?.username ?? '?',
                                  actorAvatarUrl: user?.avatarUrl,
                                  jokeId: joke.id,
                                  jokeContent: joke.contentFr,
                                );
                              }
                            }
                          }
                        : null,
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    count: joke.commentsCount,
                    color: AppColors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Share Template (Stylized snapshot for image sharing) ────────────────

class JokeShareTemplate extends StatelessWidget {
  final Joke joke;
  final AppLocalizations l10n;
  final String langCode;
  final bool isDark;

  const JokeShareTemplate({
    super.key,
    required this.joke,
    required this.l10n,
    required this.langCode,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final content = joke.localizedContent(langCode);
    final punchline = joke.localizedPunchline(langCode);
    final categoryLabel = JokeCategories.getLocalizedName(joke.category, l10n);
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      width: 400,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.all(32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textStyle = GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: textPrimary,
          );

          // Measure if text exceeds 12 lines
          final tp = TextPainter(
            text: TextSpan(text: content, style: textStyle),
            maxLines: 12,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: 400 - 64); // subtract padding

          final isTruncated = tp.didExceedMaxLines;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Author & Category
              Row(
                children: [
                  AuthorAvatar(
                    url: joke.authorAvatarUrl,
                    name: joke.authorName,
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          joke.authorName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          categoryLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Decorative quote
              Text(
                '\u201c',
                style: GoogleFonts.poppins(
                  fontSize: 64,
                  height: 0.6,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              // Joke Content
              Text(
                content,
                style: textStyle,
                maxLines: 12,
                overflow: TextOverflow.ellipsis,
              ),
              if (isTruncated) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.readFullOnKomiko,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Punchline (only show if not truncated)
              if (!isTruncated && punchline != null && punchline.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            color: AppColors.primary,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              child: Text(
                                punchline,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              // Footer Branding
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Komiko nobg.webp',
                    height: 32,
                  ),
                ],
              ),
              Text(
                l10n.tagline,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AuthorAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;

  const AuthorAvatar(
      {super.key,
      required this.url,
      required this.name,
      this.radius = 20});

  static Color bgColor(String name) {
    const colors = [
      AppColors.catAnimaux, AppColors.catBelges, AppColors.catBlondes,
      AppColors.catInformatique, AppColors.catMedecine, AppColors.catSport,
      AppColors.catToto, AppColors.catManagement,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    String? effectiveUrl = url;
    if (effectiveUrl == null && name == 'Komiko') {
      effectiveUrl = 'asset:assets/images/Komiko.webp';
    }

    if (effectiveUrl != null && effectiveUrl.startsWith('asset:')) {
      // Local Flutter asset (used by verified Komiko account)
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(effectiveUrl.substring(6)),
      );
    }
    if (effectiveUrl != null && effectiveUrl.startsWith('base64:')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage:
            MemoryImage(base64Decode(effectiveUrl.substring(7))),
      );
    }
    if (effectiveUrl != null && effectiveUrl.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(effectiveUrl),
        backgroundColor: bgColor(name),
      );
    }
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor(name),
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}

// ── Stat chip widget ──────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.count,
    required this.color,
    this.onTap,
  });

  String _format(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            _format(count),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Expandable text widget ──────────────────────────────────────────

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? textStyle;
  final Color linkColor;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 4,
    this.textStyle,
    this.linkColor = AppColors.primary,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure whether the text exceeds maxLines
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: effectiveStyle),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final needsTruncation = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: effectiveStyle,
              maxLines: _expanded ? null : widget.maxLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (needsTruncation) ...
              [
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? l10n.seeLess : l10n.seeMore,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: widget.linkColor,
                    ),
                  ),
                ),
              ],
          ],
        );
      },
    );
  }
}
