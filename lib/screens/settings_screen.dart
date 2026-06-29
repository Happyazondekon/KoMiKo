import 'package:flutter/material.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:komiko/providers/theme_provider.dart';
import 'package:komiko/services/localization_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/import_service.dart';
import 'package:komiko/models/user_model.dart';
import 'package:komiko/screens/edit_profile_screen.dart';
import 'dart:convert';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationService = Provider.of<LocalizationService>(context);
    final userService = Provider.of<UserService>(context);
    final userModel = userService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(context, userModel, l10n),
          const SizedBox(height: 30),
          _buildSettingItem(
            context,
            icon: Icons.person_outline,
            title: l10n.myJokes,
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            icon: Icons.palette_outlined,
            title: l10n.themeSettings,
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.language_outlined,
            title: l10n.language,
            trailing: DropdownButton<String>(
              value: localizationService.currentLocale.languageCode,
              items: [
                DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
              ],
              onChanged: (value) {
                if (value != null) {
                  localizationService.setLocale(Locale(value));
                }
              },
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.notifications_none,
            title: l10n.notifications,
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: l10n.helpSupport,
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            icon: Icons.download,
            title: l10n.importInitialJokes,
            onTap: () async {
              await ImportService.importInitialJokes();
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.jokesImported)));
              }
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthService>().signOut();
                if (context.mounted) {
                  context.read<UserService>().clearCache();
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logOut),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user, AppLocalizations l10n) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.startsWith('base64:'))
                  ? MemoryImage(base64Decode(user.avatarUrl!.substring(7)))
                  : const NetworkImage("https://via.placeholder.com/150") as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 20, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user?.username ?? "Jean Rieur",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (user?.bio != null && user!.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        Text(
          "${l10n.memberSince} ${user?.createdAt != null ? user!.createdAt!.year.toString() : '2023'}",
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem("128", l10n.jokesShared),
            _buildStatItem("4.2k", l10n.totalLikes),
            _buildStatItem("#12", l10n.rank),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
