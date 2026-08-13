import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/user_model.dart';
import 'package:komiko/providers/theme_provider.dart';
import 'package:komiko/screens/edit_profile_screen.dart';
import 'package:komiko/screens/help_support_screen.dart';
import 'package:komiko/screens/my_jokes_screen.dart';
import 'package:komiko/screens/notifications_screen.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/localization_service.dart';
import 'package:komiko/services/notification_service.dart';
import 'package:komiko/services/rating_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/widgets/bubble_button.dart';
import 'package:komiko/widgets/joke_card.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final uid = context.read<UserService>().currentUser?.uid;
    _statsFuture = uid != null
        ? JokeService().getUserStats(uid)
        : Future.value({'jokesCount': 0, 'totalLikes': 0, 'totalComments': 0});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationService = Provider.of<LocalizationService>(context);
    final userService = Provider.of<UserService>(context);
    final userModel = userService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/Komiko nobg.webp',
          height: 30,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(context, userModel, l10n, isDark),
          const SizedBox(height: 28),
          // Section title
          Text(
            l10n.accountSettings,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryDark,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingTile(
            context,
            icon: Icons.person_outline_rounded,
            title: l10n.myJokes,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyJokesScreen()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.palette_outlined,
            title: l10n.themeSettings,
            isDark: isDark,
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => themeProvider
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.language_outlined,
            title: l10n.language,
            isDark: isDark,
            trailing: DropdownButton<String>(
              value: localizationService.currentLocale.languageCode,
              underline: const SizedBox(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              items: [
                DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
              ],
              onChanged: (value) {
                if (value != null) localizationService.setLocale(Locale(value));
              },
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: l10n.notifications,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            trailing: StreamBuilder<int>(
              stream: NotificationService.unreadCountStream(
                  context.read<AuthService>().currentUser?.uid ?? ''),
              builder: (ctx, snap) {
                final count = snap.data ?? 0;
                if (count == 0) return const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryDark);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$count', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                );
              },
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.help_outline_rounded,
            title: l10n.helpSupport,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.star_outline_rounded,
            title: l10n.rateNow,
            isDark: isDark,
            onTap: () => RatingService().forceRequestReview(context),
          ),
          const SizedBox(height: 28),
          BubbleButton(
            onTap: () async {
              await context.read<AuthService>().signOut();
              if (context.mounted) {
                context.read<UserService>().clearCache();
              }
            },
            variant: BubbleVariant.danger,
            fullWidth: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.logOut,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  Widget _buildProfileHeader(
    BuildContext context,
    UserModel? user,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            AuthorAvatar(
              url: user?.avatarUrl,
              name: user?.username ?? '?',
              radius: 48,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                ),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Name + verified
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user?.username ?? l10n.anonymous,
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w800),
            ),
            if (user?.isVerified == true) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: l10n.verifiedAccount,
                child: const Icon(Icons.verified,
                    color: AppColors.primary, size: 22),
              ),
            ],
          ],
        ),
        if (user?.bio != null && user!.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondaryDark,
                  fontStyle: FontStyle.italic,
                  fontSize: 13),
            ),
          ),
        Text(
          '${l10n.memberSince} ${user?.createdAt?.year ?? ''}',
          style: GoogleFonts.poppins(
              color: AppColors.textSecondaryDark, fontSize: 12),
        ),
        const SizedBox(height: 20),
        // Stats row
        FutureBuilder<Map<String, int>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            final stats = snapshot.data ?? {};
            return Row(
              children: [
                _buildStatCard(
                    '${user?.followersCount ?? 0}',
                    l10n.followers,
                    cardBg,
                    border,
                    isDark),
                const SizedBox(width: 10),
                _buildStatCard(
                    '${user?.followingCount ?? 0}',
                    l10n.following,
                    cardBg,
                    border,
                    isDark),
                const SizedBox(width: 10),
                _buildStatCard(
                    '${stats['totalLikes'] ?? 0}',
                    l10n.likesReceived,
                    cardBg,
                    border,
                    isDark),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, Color bg, Color border, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondaryDark),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
