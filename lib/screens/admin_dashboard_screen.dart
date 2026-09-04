import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/models/user_model.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _jokeService = JokeService();
  final _searchController = TextEditingController();
  String _userSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Posts', icon: Icon(Icons.article_rounded, size: 18)),
            Tab(text: 'Utilisateurs', icon: Icon(Icons.people_rounded, size: 18)),
            Tab(text: 'Signalés', icon: Icon(Icons.flag_rounded, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Onglet Posts ────────────────────────────────────────────
          _PostsTab(jokeService: _jokeService, isDark: isDark, cardBg: cardBg),

          // ── Onglet Utilisateurs ─────────────────────────────────────
          _UsersTab(
            isDark: isDark,
            cardBg: cardBg,
            searchController: _searchController,
            searchQuery: _userSearchQuery,
            onSearchChanged: (v) => setState(() => _userSearchQuery = v),
          ),

          // ── Onglet Signalés ─────────────────────────────────────────
          _ReportedTab(jokeService: _jokeService, isDark: isDark, cardBg: cardBg),
        ],
      ),
    );
  }
}

// ── Onglet Posts ──────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  final JokeService jokeService;
  final bool isDark;
  final Color cardBg;

  const _PostsTab({
    required this.jokeService,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Joke>>(
      stream: jokeService.jokesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final jokes = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: jokes.length,
          itemBuilder: (context, i) =>
              _AdminJokeCard(joke: jokes[i], isDark: isDark, cardBg: cardBg),
        );
      },
    );
  }
}

class _AdminJokeCard extends StatelessWidget {
  final Joke joke;
  final bool isDark;
  final Color cardBg;

  const _AdminJokeCard({required this.joke, required this.isDark, required this.cardBg});

  @override
  Widget build(BuildContext context) {
    final jokeService = JokeService();
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: joke.isHidden
            ? AppColors.error.withValues(alpha: 0.08)
            : (joke.isFeatured
                ? AppColors.primary.withValues(alpha: 0.08)
                : cardBg),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: joke.isHidden
              ? AppColors.error.withValues(alpha: 0.3)
              : (joke.isFeatured ? AppColors.primary.withValues(alpha: 0.4) : border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auteur + badges
            Row(
              children: [
                Expanded(
                  child: Text(
                    joke.authorName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (joke.isFeatured)
                  _AdminBadge('⭐ Vedette', AppColors.primary),
                if (joke.isHidden)
                  _AdminBadge('🚫 Masqué', AppColors.error),
                if (joke.imageBase64 != null)
                  _AdminBadge('📷 Photo', AppColors.blue),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              joke.contentFr,
              style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (joke.imageBase64 != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(joke.imageBase64!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Stats
            Row(
              children: [
                Icon(Icons.favorite_rounded, size: 14, color: AppColors.pink),
                const SizedBox(width: 4),
                Text('${joke.likesCount}',
                    style: GoogleFonts.poppins(fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.comment_rounded, size: 14, color: AppColors.blue),
                const SizedBox(width: 4),
                Text('${joke.commentsCount}',
                    style: GoogleFonts.poppins(fontSize: 12)),
                if (joke.reportCount > 0) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.flag_rounded, size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text('${joke.reportCount}',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.error)),
                ],
                const Spacer(),
                // Actions
                _AdminActionButton(
                  icon: joke.isFeatured
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppColors.primary,
                  tooltip: joke.isFeatured ? 'Retirer vedette' : 'Mettre vedette',
                  onTap: () => jokeService.setFeatured(joke.id, !joke.isFeatured),
                ),
                const SizedBox(width: 4),
                _AdminActionButton(
                  icon: joke.isHidden
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: joke.isHidden ? Colors.green : Colors.orange,
                  tooltip: joke.isHidden ? 'Afficher' : 'Masquer',
                  onTap: () => jokeService.setHidden(joke.id, !joke.isHidden),
                ),
                const SizedBox(width: 4),
                _AdminActionButton(
                  icon: Icons.delete_rounded,
                  color: AppColors.error,
                  tooltip: 'Supprimer',
                  onTap: () => _confirmDelete(context, jokeService, joke.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, JokeService jokeService, String jokeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer ce post ?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Cette action est irréversible.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await jokeService.deleteJoke(jokeId);
            },
            child: Text('Supprimer',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Onglet Utilisateurs ───────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _UsersTab({
    required this.isDark,
    required this.cardBg,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final userService = context.read<UserService>();

    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou email...',
              hintStyle: GoogleFonts.poppins(fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: userService.allUsersStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              var users = snapshot.data!;
              if (searchQuery.isNotEmpty) {
                final lower = searchQuery.toLowerCase();
                users = users
                    .where((u) =>
                        (u.username?.toLowerCase().contains(lower) ?? false) ||
                        (u.email?.toLowerCase().contains(lower) ?? false))
                    .toList();
              }
              if (users.isEmpty) {
                return Center(
                  child: Text('Aucun utilisateur trouvé',
                      style: GoogleFonts.poppins(color: AppColors.textSecondaryDark)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: users.length,
                itemBuilder: (context, i) => _AdminUserCard(
                  user: users[i],
                  isDark: isDark,
                  cardBg: cardBg,
                  border: border,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final Color cardBg;
  final Color border;

  const _AdminUserCard({
    required this.user,
    required this.isDark,
    required this.cardBg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final userService = context.read<UserService>();

    Color bgColor = cardBg;
    Color borderColor = border;
    if (user.isBanned) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.3);
    } else if (user.isRestricted) {
      bgColor = Colors.orange.withValues(alpha: 0.08);
      borderColor = Colors.orange.withValues(alpha: 0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar initiales
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    (user.username ?? '?')[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.username ?? 'Sans nom',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          if (user.effectiveIsVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppColors.primary, size: 14),
                          ],
                          if (user.hasActivePro) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.workspace_premium_rounded,
                                color: Color(0xFFFFD700), size: 14),
                          ],
                        ],
                      ),
                      Text(
                        user.email ?? 'Pas d\'email',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                // Badges statut
                if (user.isBanned) _AdminBadge('Banni', AppColors.error),
                if (user.isRestricted && !user.isBanned)
                  _AdminBadge('Restreint', Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Vérification
                _AdminChipButton(
                  label: user.isVerified ? 'Retirer ✓' : 'Vérifier ✓',
                  color: user.isVerified ? Colors.grey : AppColors.primary,
                  onTap: () => userService.setVerified(user.uid, !user.isVerified),
                ),
                // Pro
                _AdminChipButton(
                  label: user.hasActivePro ? 'Retirer Pro' : 'Accorder Pro',
                  color: user.hasActivePro ? Colors.grey : const Color(0xFFFFD700),
                  onTap: () => user.hasActivePro
                      ? userService.revokePro(user.uid)
                      : userService.grantPro(user.uid),
                ),
                // Restriction
                _AdminChipButton(
                  label: user.isRestricted ? 'Lever restriction' : 'Restreindre',
                  color: user.isRestricted ? Colors.green : Colors.orange,
                  onTap: () => user.isRestricted
                      ? userService.unrestrictUser(user.uid)
                      : _showRestrictDialog(context, userService, user.uid),
                ),
                // Bannissement
                _AdminChipButton(
                  label: user.isBanned ? 'Débannir' : 'Bannir',
                  color: user.isBanned ? Colors.green : AppColors.error,
                  onTap: () => user.isBanned
                      ? userService.unbanUser(user.uid)
                      : _showBanDialog(context, userService, user.uid),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRestrictDialog(BuildContext context, UserService userService, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restreindre cet utilisateur',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Raison (optionnel)',
            border: const OutlineInputBorder(),
            hintStyle: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(ctx);
              await userService.restrictUser(uid,
                  reason: controller.text.isNotEmpty ? controller.text : null);
            },
            child: Text('Restreindre',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context, UserService userService, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bannir cet utilisateur',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.error)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Raison du bannissement',
            border: const OutlineInputBorder(),
            hintStyle: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await userService.banUser(uid,
                  reason: controller.text.isNotEmpty ? controller.text : null);
            },
            child: Text('Bannir', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Onglet Signalés ───────────────────────────────────────────────────────────

class _ReportedTab extends StatelessWidget {
  final JokeService jokeService;
  final bool isDark;
  final Color cardBg;

  const _ReportedTab({
    required this.jokeService,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Joke>>(
      stream: jokeService.reportedJokesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final jokes = snapshot.data!;
        if (jokes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Aucun contenu signalé 🎉',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: jokes.length,
          itemBuilder: (context, i) =>
              _AdminJokeCard(joke: jokes[i], isDark: isDark, cardBg: cardBg),
        );
      },
    );
  }
}

// ── Widgets utilitaires ───────────────────────────────────────────────────────

class _AdminBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _AdminBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _AdminActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _AdminActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _AdminChipButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminChipButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
