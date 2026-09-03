import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/widgets/app_tutorial_tour_overlay.dart';
import 'package:komiko/widgets/welcome_username_dialog.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  /// Permet de relancer le didacticiel depuis n'importe quel écran (ex: Settings)
  static void startTutorial(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainScreenState>();
    state?.restartTutorial();
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showTutorial = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeFlow();
    });
  }

  Future<void> _checkFirstTimeFlow() async {
    // 1. Étape nom d'utilisateur (si pas encore validé)
    final needsUsername = await WelcomeUsernameDialog.shouldShow();
    if (needsUsername && mounted) {
      await WelcomeUsernameDialog.showIfNeeded(context);
    }

    // 2. Étape parcours didacticiel des onglets (si pas encore complété)
    final needsTutorial = await AppTutorialTourOverlay.shouldShow();
    if (needsTutorial && mounted) {
      setState(() {
        _currentIndex = 0;
        _showTutorial = true;
      });
    }
  }

  void restartTutorial() {
    setState(() {
      _currentIndex = 0;
      _showTutorial = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: _KomikoBottomNav(
            currentIndex: _currentIndex,
            isDark: isDark,
            labels: [
              l10n.home,
              l10n.categories,
              l10n.favorites,
              l10n.settings,
            ],
            icons: const [
              Icons.home_rounded,
              Icons.grid_view_rounded,
              Icons.favorite_rounded,
              Icons.settings_rounded,
            ],
            onTap: (i) {
              if (!_showTutorial) {
                setState(() => _currentIndex = i);
              }
            },
          ),
        ),

        // Overlay didacticiel interactif
        if (_showTutorial)
          AppTutorialTourOverlay(
            onTabChangeRequested: (tabIndex) {
              setState(() => _currentIndex = tabIndex);
            },
            onFinished: () {
              setState(() {
                _showTutorial = false;
                _currentIndex = 0;
              });
            },
          ),
      ],
    );
  }
}

class _KomikoBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  const _KomikoBottomNav({
    required this.currentIndex,
    required this.isDark,
    required this.labels,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(icons.length, (i) {
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          icons[i],
                          size: 22,
                          color: isActive
                              ? Colors.black
                              : (isDark ? Colors.grey[500] : Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

