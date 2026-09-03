import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final int targetTabIndex;

  const AppTutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.targetTabIndex,
  });
}

class AppTutorialTourOverlay extends StatefulWidget {
  final ValueChanged<int> onTabChangeRequested;
  final VoidCallback onFinished;

  const AppTutorialTourOverlay({
    super.key,
    required this.onTabChangeRequested,
    required this.onFinished,
  });

  static const String prefKey = 'has_completed_app_tutorial';

  /// Vérifie si le didacticiel doit être lancé à la première ouverture.
  static Future<bool> shouldShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(prefKey) ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Marque le didacticiel comme terminé.
  static Future<void> markCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKey, true);
    } catch (_) {}
  }

  /// Réinitialise pour permettre de rejouer le didacticiel.
  static Future<void> resetTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKey, false);
    } catch (_) {}
  }

  @override
  State<AppTutorialTourOverlay> createState() => _AppTutorialTourOverlayState();
}

class _AppTutorialTourOverlayState extends State<AppTutorialTourOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<AppTutorialStep> _getSteps(AppLocalizations l10n) {
    return [
      AppTutorialStep(
        title: l10n.tutorialStepFeedTitle,
        description: l10n.tutorialStepFeedDesc,
        icon: Icons.dynamic_feed_rounded,
        targetTabIndex: 0,
      ),
      AppTutorialStep(
        title: l10n.tutorialStepProposeTitle,
        description: l10n.tutorialStepProposeDesc,
        icon: Icons.add_circle_outline_rounded,
        targetTabIndex: 0,
      ),
      AppTutorialStep(
        title: l10n.tutorialStepCategoriesTitle,
        description: l10n.tutorialStepCategoriesDesc,
        icon: Icons.grid_view_rounded,
        targetTabIndex: 1,
      ),
      AppTutorialStep(
        title: l10n.tutorialStepFavoritesTitle,
        description: l10n.tutorialStepFavoritesDesc,
        icon: Icons.favorite_rounded,
        targetTabIndex: 2,
      ),
      AppTutorialStep(
        title: l10n.tutorialStepSettingsTitle,
        description: l10n.tutorialStepSettingsDesc,
        icon: Icons.settings_rounded,
        targetTabIndex: 3,
      ),
    ];
  }

  void _nextStep(List<AppTutorialStep> steps) {
    if (_currentStepIndex < steps.length - 1) {
      _animController.reverse().then((_) {
        setState(() {
          _currentStepIndex++;
        });
        widget.onTabChangeRequested(steps[_currentStepIndex].targetTabIndex);
        _animController.forward();
      });
    } else {
      _finish();
    }
  }

  void _finish() async {
    await AppTutorialTourOverlay.markCompleted();
    widget.onTabChangeRequested(0);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = _getSteps(l10n);
    final currentStep = steps[_currentStepIndex];
    final isLast = _currentStepIndex == steps.length - 1;

    return Stack(
      children: [
        // Fond semi-transparent interceptant les clics involontaires
        GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),
        ),

        // Carte interactive du didacticiel
        Positioned(
          left: 16,
          right: 16,
          bottom: 76, // Au-dessus de la bottom nav
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 28,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête : Icône, Étape X/5, Bouton Passer
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          currentStep.icon,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_currentStepIndex + 1} / ${steps.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _finish,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            l10n.tutorialSkip,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Titre
                  Text(
                    currentStep.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    currentStep.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textSecondaryDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Indicateur de progression + Bouton Suivant
                  Row(
                    children: [
                      // Petites pastilles de progression
                      Row(
                        children: List.generate(steps.length, (i) {
                          final active = i == _currentStepIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 4),
                            width: active ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                      ? Colors.grey[700]
                                      : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),

                      // Bouton Suivant / Terminer
                      ElevatedButton(
                        onPressed: () => _nextStep(steps),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? l10n.tutorialFinish : l10n.tutorialNext,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isLast
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
}
