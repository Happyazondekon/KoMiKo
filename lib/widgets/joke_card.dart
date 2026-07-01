import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/screens/joke_detail_screen.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/notification_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class JokeCard extends StatelessWidget {
  final Joke joke;

  const JokeCard({super.key, required this.joke});

  @override
  Widget build(BuildContext context) {
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
              // â”€â”€ Author row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Row(
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
                            if (joke.isAuthorVerified) ...
                              [
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    color: AppColors.primary, size: 14),
                              ],
                          ],
                        ),
                        Text(
                          '$ago â€¢ $categoryLabel',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share icon
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: isDark
                          ? Colors.grey[500]
                          : Colors.grey[600],
                    ),
                    onPressed: () => Share.share(
                        '$content\n\n${punchline ?? ''}\n\n${l10n.shareViaKomiko}'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // â”€â”€ Joke content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text(
                content,
                style: GoogleFonts.poppins(
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
                  Text(
                    punchline,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              const SizedBox(height: 14),
              // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€ Avatar widget (public â€” reused by JokeDetailScreen) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    if (url != null && url!.startsWith('asset:')) {
      // Local Flutter asset (used by verified Komiko account)
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(url!.substring(6)),
      );
    }
    if (url != null && url!.startsWith('base64:')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage:
            MemoryImage(base64Decode(url!.substring(7))),
      );
    }
    if (url != null && url!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url!),
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

// â”€â”€ Stat chip widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
