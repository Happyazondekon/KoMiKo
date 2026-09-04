import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/widgets/bubble_button.dart';

/// Dialogue de remerciement et de félicitations affiché après un abonnement Komiko Pro réussi.
class ProThankYouDialog extends StatelessWidget {
  const ProThankYouDialog({super.key});

  /// Affiche le dialogue avec une belle animation modale.
  static Future<void> show(BuildContext context) async {
    HapticFeedback.heavyImpact();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ProThankYouDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Illustration officielle two.webp ────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: isDark
                      ? AppColors.darkBackground.withValues(alpha: 0.5)
                      : const Color(0xFFFFF9E6),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/illustrations/two.webp',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Badge doré Pro ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE082), Color(0xFFFFD700)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.black87, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'KOMIKO PRO',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Titre ───────────────────────────────────────────────────
              Text(
                l10n.proThankYouTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              // ── Sous-titre ──────────────────────────────────────────────
              Text(
                l10n.proThankYouSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // ── Liste des avantages débloqués ───────────────────────────
              _BenefitRow(
                icon: Icons.verified_rounded,
                text: l10n.proBenefitBadge,
                color: const Color(0xFFFFD700),
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _BenefitRow(
                icon: Icons.auto_awesome_rounded,
                text: l10n.proBenefitAssistant,
                color: const Color(0xFFFFD700),
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _BenefitRow(
                icon: Icons.image_rounded,
                text: l10n.proBenefitPhotos,
                color: const Color(0xFFFFD700),
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _BenefitRow(
                icon: Icons.rocket_launch_rounded,
                text: l10n.proBenefitBoost,
                color: const Color(0xFFFFD700),
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // ── Bouton d'action principal ───────────────────────────────
              BubbleButton(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
                label: l10n.proThankYouButton,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isDark;

  const _BenefitRow({
    required this.icon,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.6)
            : AppColors.lightBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
