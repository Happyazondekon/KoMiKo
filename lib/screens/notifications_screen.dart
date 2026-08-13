import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/notification_model.dart';
import 'package:komiko/screens/joke_detail_screen.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/notification_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:komiko/widgets/joke_card.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final userId = context.read<AuthService>().currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.notifications,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: userId.isNotEmpty
                ? () async {
                    // Mark as read in Firestore
                    await NotificationService.markAllRead(userId);
                    
                    // Actually DELETE the notifications from the database
                    final db = FirebaseFirestore.instance;
                    final snaps = await db
                        .collection('notifications')
                        .where('recipientId', isEqualTo: userId)
                        .get();
                        
                    final batch = db.batch();
                    for (var doc in snaps.docs) {
                      batch.delete(doc.reference);
                    }
                    await batch.commit();
                  }
                : null,
            child: Text(
              l10n.markAllRead,
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: userId.isEmpty
          ? _buildEmpty(l10n, isDark)
          : StreamBuilder<List<AppNotification>>(
              stream: NotificationService.getNotificationsStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return KomikoError(message: l10n.errorOops, onRetry: null);
                }
                final notifs = snapshot.data ?? [];
                if (notifs.isEmpty) return _buildEmpty(l10n, isDark);

                return ListView.builder(
                  itemCount: notifs.length,
                  itemBuilder: (context, i) => _NotifTile(
                    notif: notifs[i],
                    l10n: l10n,
                    langCode: langCode,
                    isDark: isDark,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/illustrations/four.webp', height: 120),
          const SizedBox(height: 16),
          Text(
            l10n.noNotifications,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondaryDark,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final AppLocalizations l10n;
  final String langCode;
  final bool isDark;

  const _NotifTile({
    required this.notif,
    required this.l10n,
    required this.langCode,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = notif.isRead
        ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
        : (isDark
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.primary.withValues(alpha: 0.08));
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final message = notif.type == 'like'
        ? l10n.notifLiked(notif.actorName)
        : l10n.notifCommented(notif.actorName);

    return InkWell(
      onTap: () {
        NotificationService.markRead(notif.id);
        JokeService().jokesStream.first.then((jokes) {
          final joke = jokes.where((j) => j.id == notif.jokeId).firstOrNull;
          if (joke != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JokeDetailScreen(joke: joke)),
            );
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            AuthorAvatar(
              url: notif.actorAvatarUrl,
              name: notif.actorName,
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  if (notif.jokeContent != null)
                    Text(
                      notif.jokeContent!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  Text(
                    timeAgo(notif.createdAt, langCode),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Error Widget ────────────────────────────────────────────────────

class KomikoError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const KomikoError({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/illustrations/all_error.webp', height: 160),
            const SizedBox(height: 16),
            Text(
              message ?? l10n.errorOops,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textSecondaryDark,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
