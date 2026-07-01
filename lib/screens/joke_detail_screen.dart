import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/comment_model.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/notification_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:komiko/widgets/joke_card.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class JokeDetailScreen extends StatefulWidget {
  final Joke joke;
  const JokeDetailScreen({super.key, required this.joke});

  @override
  State<JokeDetailScreen> createState() => _JokeDetailScreenState();
}

class _JokeDetailScreenState extends State<JokeDetailScreen> {
  final _commentController = TextEditingController();
  final _jokeService = JokeService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final user = context.read<UserService>().currentUser;
      if (user == null) return;

      final comment = Comment(
        id: '',
        jokeId: widget.joke.id,
        content: content,
        authorName: user.username ?? context.read<AppLocalizations>().anonymous,
        authorId: user.uid,
        authorAvatarUrl: user.avatarUrl,
        createdAt: DateTime.now(),
      );

      await _jokeService.addComment(comment);
      _commentController.clear();
      // Notify the joke author
      if (widget.joke.authorId != user.uid) {
        NotificationService.createCommentNotification(
          recipientId: widget.joke.authorId,
          actorId: user.uid,
          actorName: user.username ?? '?',
          actorAvatarUrl: user.avatarUrl,
          jokeId: widget.joke.id,
          jokeContent: widget.joke.contentFr,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final user = context.watch<UserService>().currentUser;
    final isLiked = widget.joke.likedBy.contains(user?.uid ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = widget.joke.localizedContent(langCode);
    final punchline = widget.joke.localizedPunchline(langCode);
    final categoryLabel =
        JokeCategories.getLocalizedName(widget.joke.category, l10n);
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryLabel,
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => Share.share(
                '$content\n\n${punchline ?? ''}\n\n${l10n.shareViaKomiko}'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Author row ──────────────────────────────────────────
                  Row(
                    children: [
                      AuthorAvatar(
                        url: widget.joke.authorAvatarUrl,
                        name: widget.joke.authorName,
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.joke.authorName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                if (widget.joke.isAuthorVerified) ...[
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message: l10n.verifiedAccount,
                                    child: const Icon(Icons.verified,
                                        color: AppColors.primary,
                                        size: 15),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              timeAgo(widget.joke.createdAt, langCode),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.forCategory(widget.joke.category)
                              .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // ── Decorative quote ────────────────────────────────────
                  Text(
                    '\u201c',
                    style: GoogleFonts.poppins(
                      fontSize: 72,
                      height: 0.6,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Joke content ────────────────────────────────────────
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  // ── Punchline ───────────────────────────────────────────
                  if (punchline != null && punchline.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                              color: AppColors.primary, width: 4),
                          right: BorderSide(color: border),
                          top: BorderSide(color: border),
                          bottom: BorderSide(color: border),
                        ),
                      ),
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
                  ],
                  const SizedBox(height: 28),
                  // ── Action buttons ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () => Share.share(
                              '$content\n\n${punchline ?? ''}\n\n${l10n.shareViaKomiko}'),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: Text(l10n.share),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _LikeButton(
                        jokeId: widget.joke.id,
                        userId: user?.uid ?? '',
                        isLiked: isLiked,
                        likesCount: widget.joke.likesCount,
                        jokeService: _jokeService,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ── Comments header ─────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        l10n.comments,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.joke.commentsCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Comments list ───────────────────────────────────────
                  StreamBuilder<List<Comment>>(
                    stream: _jokeService.getCommentsStream(widget.joke.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            '${l10n.error}: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        );
                      }
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary));
                      }
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              l10n.noComments,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = comments[index];
                          final avatarUrl = c.authorAvatarUrl;
                          ImageProvider? avatarProvider;
                          if (avatarUrl != null &&
                              avatarUrl.startsWith('base64:')) {
                            avatarProvider = MemoryImage(
                                base64Decode(avatarUrl.substring(7)));
                          }
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: avatarProvider,
                                  backgroundColor: AppColors.forCategory(
                                      widget.joke.category),
                                  child: avatarProvider == null
                                      ? Text(
                                          c.authorName.isNotEmpty
                                              ? c.authorName[0].toUpperCase()
                                              : '?',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.authorName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.content,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // ── Comment input ───────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                  top: BorderSide(color: border)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              left: 16,
              right: 16,
              top: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: l10n.addComment,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: _submitComment,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.black, size: 20),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Like button widget ───────────────────────────────────────────────

class _LikeButton extends StatelessWidget {
  final String jokeId;
  final String userId;
  final bool isLiked;
  final int likesCount;
  final JokeService jokeService;

  const _LikeButton({
    required this.jokeId,
    required this.userId,
    required this.isLiked,
    required this.likesCount,
    required this.jokeService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: userId.isNotEmpty
          ? () => jokeService.likeJoke(jokeId, userId)
          : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isLiked
              ? AppColors.pink
              : AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isLiked ? Colors.white : AppColors.pink,
              size: 20,
            ),
            if (likesCount > 0)
              Text(
                likesCount >= 1000
                    ? '${(likesCount / 1000).toStringAsFixed(1)}k'
                    : '$likesCount',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isLiked ? Colors.white : AppColors.pink,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

