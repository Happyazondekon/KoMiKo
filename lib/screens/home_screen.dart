import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/providers/theme_provider.dart';
import 'package:komiko/screens/admin_dashboard_screen.dart';
import 'package:komiko/screens/edit_profile_screen.dart';
import 'package:komiko/screens/joke_detail_screen.dart';
import 'package:komiko/screens/my_jokes_screen.dart';
import 'package:komiko/screens/pro_upgrade_screen.dart';
import 'package:komiko/screens/propose_joke_screen.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/localization_service.dart';
import 'package:komiko/services/notification_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:komiko/widgets/bubble_button.dart';
import 'package:komiko/widgets/joke_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Schedule the 3 daily notifications on launch
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      await NotificationService.scheduleMultipleDailyNotifications(l10n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final jokeService = JokeService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = context.watch<UserService>().currentUser;

    return Scaffold(
      drawer: const KomikoDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/images/Komiko nobg.webp',
          height: 30,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            onPressed: () => showSearch(
              context: context,
              delegate: JokeSearchDelegate(
                jokeService: JokeService(),
                l10n: l10n,
                langCode: langCode,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProposeJokeScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        tooltip: l10n.proposeJoke,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        color: AppColors.primary,
        onRefresh: () async {
          // Le stream Firestore se rafraîchit automatiquement.
          // On force juste un court délai pour l'animation.
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          slivers: [
            // ── Notification Permission Prompt ─────────────────────────
            SliverToBoxAdapter(
              child: FutureBuilder<PermissionStatus>(
                future: Permission.notification.status,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != PermissionStatus.granted) {
                    return _NotificationPromptCard(l10n: l10n, isDark: isDark);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            // ── A LA UNE hero card ─────────────────────────────────────
            SliverToBoxAdapter(
              child: StreamBuilder<Joke?>(
                stream: jokeService.dailyJokeStream,
                builder: (context, snapshot) {
                  final joke = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: GestureDetector(
                      onTap: joke != null
                          ? () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      JokeDetailScreen(joke: joke)))
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: joke == null
                            ? const Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(
                                      color: Colors.black54),
                                ),
                              )
                            : _DailyJokeContent(
                                joke: joke, langCode: langCode, l10n: l10n),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Section header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.feedForYou,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            l10n.feedSelectedForYou,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Smart Feed ─────────────────────────────────────────────
            StreamBuilder<List<Joke>>(
              stream: jokeService.feedStream(currentUserId: currentUser?.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('${l10n.error}: ${snapshot.error}'),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    ),
                  );
                }
                final jokes = snapshot.data ?? [];
                if (jokes.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(l10n.noJokes),
                      ),
                    ),
                  );
                }
                final isProUser = currentUser?.hasActivePro ?? false;
                final showAiCard = !isProUser && jokes.length >= 3;
                final totalCount = showAiCard ? jokes.length + 1 : jokes.length;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (showAiCard && index == 3) {
                        return const _ProPromoFeedCard();
                      }
                      final jokeIndex = (showAiCard && index > 3) ? index - 1 : index;
                      return JokeCard(joke: jokes[jokeIndex]);
                    },
                    childCount: totalCount,
                  ),
                );
              },
            ),

            // ── Random joke button ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: BubbleButton(
                  onTap: () async {
                    final random = await jokeService.getRandomJoke();
                    if (random != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => JokeDetailScreen(joke: random)),
                      );
                    }
                  },
                  label: l10n.randomJoke,
                  fullWidth: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.casino_rounded, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        l10n.randomJoke,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        ),
      ),
    );
  }
}

// ── Notification Prompt Widget ──────────────────────────────────────

class _NotificationPromptCard extends StatefulWidget {
  final AppLocalizations l10n;
  final bool isDark;
  const _NotificationPromptCard({required this.l10n, required this.isDark});

  @override
  State<_NotificationPromptCard> createState() => _NotificationPromptCardState();
}

class _NotificationPromptCardState extends State<_NotificationPromptCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final border = widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardBg = widget.isDark ? AppColors.darkCard : AppColors.lightCard;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: AppColors.pink),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, 
                              color: AppColors.pink, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.l10n.notifStatusTitle,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.pink,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _isVisible = false),
                            child: Icon(Icons.close_rounded, 
                                size: 18, color: Colors.grey.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.l10n.enableNotifPrompt,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final granted = await NotificationService.requestPermission();
                            if (granted) {
                              if (context.mounted) {
                                setState(() => _isVisible = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(widget.l10n.permissionGranted), 
                                  backgroundColor: Colors.green),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            widget.l10n.enableNotifButton,
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily joke content widget ──────────────────────────────────

class _DailyJokeContent extends StatelessWidget {
  final Joke joke;
  final String langCode;
  final AppLocalizations l10n;

  const _DailyJokeContent({
    required this.joke,
    required this.langCode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final content = joke.localizedContent(langCode);
    final punchline = joke.localizedPunchline(langCode);
    final catLabel =
        JokeCategories.getLocalizedName(joke.category, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // À LA UNE chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.dailyJoke.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Spacer(),
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (joke.isAuthorVerified)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.verified,
                          size: 12, color: Colors.black54),
                    ),
                  Text(
                    catLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Joke content
        ExpandableText(
          text: content,
          maxLines: 5,
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            height: 1.3,
          ),
          linkColor: Colors.black87,
        ),
        if (punchline != null && punchline.isNotEmpty) ...
          [
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpandableText(
                text: punchline,
                maxLines: 3,
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                linkColor: Colors.black54,
              ),
            ),
          ],
      ],
    );
  }
}

// ══ Komiko Drawer ════════════════════════════════════════════════════════════
// Accessible from HomeScreen and CategoriesScreen hamburger menus.

class KomikoDrawer extends StatelessWidget {
  const KomikoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<UserService>().currentUser;
    final themeProvider = context.watch<ThemeProvider>();
    final localization = context.watch<LocalizationService>();
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      );
                    },
                    child: _drawerAvatar(user),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.username ?? l10n.anonymous,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user?.isVerified == true) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  color: AppColors.primary, size: 16),
                            ],
                          ],
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email!,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondaryDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                children: [
                  _DrawerTile(
                    icon: Icons.person_outline_rounded,
                    label: l10n.myJokes,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const MyJokesScreen()));
                    },
                    cardBg: cardBg,
                    border: border,
                  ),
                  // ── Komiko Pro (élément visible pour les non-Pro) ────
                  if (!(user?.hasActivePro ?? false))
                    _DrawerTile(
                      icon: Icons.workspace_premium_rounded,
                      label: l10n.komikoProBadge,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProUpgradeScreen()),
                        );
                      },
                      cardBg: AppColors.primary.withValues(alpha: 0.08),
                      border: AppColors.primary.withValues(alpha: 0.3),
                      iconColor: AppColors.primary,
                      labelColor: AppColors.primary,
                    ),
                  // ── Admin Dashboard (visible uniquement pour Komiko) ────
                  if (user?.role == 'komiko' || user?.uid == 'UK42noQ7qiVt63v3PHHywdZQajS2')
                    _DrawerTile(
                      icon: Icons.admin_panel_settings_rounded,
                      label: l10n.adminDashboard,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                      cardBg: Colors.purple.withValues(alpha: 0.08),
                      border: Colors.purple.withValues(alpha: 0.3),
                      iconColor: Colors.purple,
                      labelColor: Colors.purple,
                    ),
                  _DrawerTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    label: l10n.themeSettings,
                    onTap: () {},
                    cardBg: cardBg,
                    border: border,
                    trailing: Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => themeProvider.setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.language_outlined,
                    label: l10n.language,
                    onTap: () {},
                    cardBg: cardBg,
                    border: border,
                    trailing: DropdownButton<String>(
                      value:
                          localization.currentLocale.languageCode,
                      underline: const SizedBox(),
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                      items: [
                        DropdownMenuItem(
                            value: 'fr', child: Text(l10n.french)),
                        DropdownMenuItem(
                            value: 'en', child: Text(l10n.english)),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          localization.setLocale(Locale(v));
                        }
                      },
                    ),
                  ),
                  _DrawerTile(
                    icon: Icons.notifications_none_rounded,
                    label: l10n.notifications,
                    onTap: () => Navigator.pop(context),
                    cardBg: cardBg,
                    border: border,
                  ),
                  _DrawerTile(
                    icon: Icons.help_outline_rounded,
                    label: l10n.helpSupport,
                    onTap: () => Navigator.pop(context),
                    cardBg: cardBg,
                    border: border,
                  ),
                  const SizedBox(height: 8),
                  Divider(color: border),
                  const SizedBox(height: 8),
                  _DrawerTile(
                    icon: Icons.logout_rounded,
                    label: l10n.logOut,
                    onTap: () async {
                      Navigator.pop(context);
                      await context.read<AuthService>().signOut();
                      if (context.mounted) {
                        context.read<UserService>().clearCache();
                      }
                    },
                    cardBg: AppColors.error.withValues(alpha: 0.08),
                    border: AppColors.error.withValues(alpha: 0.3),
                    iconColor: AppColors.error,
                    labelColor: AppColors.error,
                  ),
                ],
              ),
            ),
            // Version note
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Komiko v1.1.0',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerAvatar(dynamic user) {
    return AuthorAvatar(
      url: user?.avatarUrl as String?,
      name: user?.username as String? ?? '?',
      radius: 24,
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color cardBg;
  final Color border;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cardBg,
    required this.border,
    this.trailing,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final ic = iconColor ?? AppColors.primary;
    final lc = labelColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ic.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ic, size: 18),
          ),
          title: Text(label,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: lc)),
          trailing: trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondaryDark, size: 18),
          dense: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ══ Search Delegate ═══════════════════════════════════════════════════════════

class JokeSearchDelegate extends SearchDelegate<Joke?> {
  final JokeService jokeService;
  final AppLocalizations l10n;
  final String langCode;

  JokeSearchDelegate({
    required this.jokeService,
    required this.l10n,
    required this.langCode,
  }) : super(searchFieldLabel: l10n.searchPlaceholder);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(fontSize: 16),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_rounded,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              l10n.typeAWordOrPhrase,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondaryDark),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Joke>>(
      future: jokeService.searchJokes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('${l10n.error}: ${snapshot.error}'));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  l10n.noResultsFor(query),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, i) => JokeCard(joke: results[i]),
        );
      },
    );
  }
}

// ── Carte promotionnelle Pro dans le Feed ────────────────────────────────────

class _ProPromoFeedCard extends StatefulWidget {
  const _ProPromoFeedCard();

  @override
  State<_ProPromoFeedCard> createState() => _ProPromoFeedCardState();
}

class _ProPromoFeedCardState extends State<_ProPromoFeedCard> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            const Color(0xFFFFD700).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, size: 13, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        l10n.komikoPro,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _dismissed = true),
                  child: Icon(Icons.close_rounded,
                      size: 16,
                      color: isDark ? AppColors.textSecondaryDark : Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.proUpgradeBannerSubtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProUpgradeScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.proUpgradeBannerTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
