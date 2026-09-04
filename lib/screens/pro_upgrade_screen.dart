import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/services/purchase_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/widgets/pro_thank_you_dialog.dart';
import 'package:provider/provider.dart';

class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  PurchaseService? _purchaseService;
  bool _dialogShowing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = Provider.of<PurchaseService>(context);
    if (_purchaseService != service) {
      _purchaseService?.removeListener(_onPurchaseUpdate);
      _purchaseService = service;
      _purchaseService?.addListener(_onPurchaseUpdate);
    }
  }

  @override
  void dispose() {
    _purchaseService?.removeListener(_onPurchaseUpdate);
    super.dispose();
  }

  void _onPurchaseUpdate() {
    final status = _purchaseService?.status;
    if ((status == PurchaseStatus.purchasedPro ||
            (status == PurchaseStatus.restored && (_purchaseService?.isPro ?? false))) &&
        !_dialogShowing &&
        mounted) {
      _dialogShowing = true;

      // Recharger le profil utilisateur avec son statut Pro & badge vérifié
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<UserService>().loadUserProfile(uid, forceReload: true);
      }

      _purchaseService?.resetStatus();

      // Afficher le popup de remerciement officiel avec l'illustration two.webp
      ProThankYouDialog.show(context).then((_) {
        if (mounted) {
          Navigator.of(context).pop(); // Fermer l'écran d'upgrade
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // ── Hero Logo Komiko ─────────────────────────────────────
              Center(
                child: Image.asset(
                  AppAssets.komikoLogoForDark(isDark),
                  height: 105,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n.komikoPro,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              Center(
                child: Text(
                  l10n.komikoProUnlock,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondaryDark,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Avantages (sans photos, comme demandé) ────────────────
              _ProFeature(
                icon: Icons.verified_rounded,
                title: l10n.proFeatureBadgeTitle,
                desc: l10n.proFeatureBadgeDesc,
                isDark: isDark,
              ),
              _ProFeature(
                icon: Icons.rocket_launch_rounded,
                title: l10n.proFeatureBoostTitle,
                desc: l10n.proFeatureBoostDesc,
                isDark: isDark,
              ),
              _ProFeature(
                icon: Icons.trending_up_rounded,
                title: l10n.proFeaturePriorityTitle,
                desc: l10n.proFeaturePriorityDesc,
                isDark: isDark,
              ),
              const SizedBox(height: 32),

              // ── Plans ─────────────────────────────────────────────────
              Consumer<PurchaseService>(
                builder: (context, purchaseService, _) {
                  final monthly = purchaseService.getProduct(KomikoProducts.proMonthly);
                  final annual = purchaseService.getProduct(KomikoProducts.proAnnual);
                  final isLoading = purchaseService.status == PurchaseStatus.loading;

                  return Column(
                    children: [
                      // Plan mensuel
                      _PlanCard(
                        title: l10n.planMonthly,
                        price: monthly?.price ?? '1,99 €',
                        period: l10n.planPerMonth,
                        isBestValue: false,
                        isDark: isDark,
                        isLoading: isLoading,
                        onTap: monthly != null
                            ? () => purchaseService.buySubscription(monthly)
                            : null,
                        unavailable: monthly == null,
                        unavailableLabel: l10n.comingSoon,
                        popularLabel: l10n.popular,
                      ),
                      const SizedBox(height: 12),
                      // Plan annuel (meilleur choix)
                      _PlanCard(
                        title: l10n.planAnnual,
                        price: annual?.price ?? '14,99 €',
                        period: l10n.planPerYear,
                        subtitle: l10n.savePercent,
                        isBestValue: true,
                        isDark: isDark,
                        isLoading: isLoading,
                        onTap: annual != null
                            ? () => purchaseService.buySubscription(annual)
                            : null,
                        unavailable: annual == null,
                        unavailableLabel: l10n.comingSoon,
                        popularLabel: l10n.popular,
                      ),
                      const SizedBox(height: 20),
                      // Restaurer les achats
                      TextButton(
                        onPressed: () => purchaseService.restorePurchases(),
                        child: Text(
                          l10n.restorePurchases,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (purchaseService.status == PurchaseStatus.error &&
                          purchaseService.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          purchaseService.errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        l10n.autoRenewDisclaimer,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondaryDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _ProFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isDark;

  const _ProFeature({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                    height: 1.4,
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

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? subtitle;
  final bool isBestValue;
  final bool isDark;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool unavailable;
  final String unavailableLabel;
  final String popularLabel;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    this.subtitle,
    required this.isBestValue,
    required this.isDark,
    required this.isLoading,
    this.onTap,
    this.unavailable = false,
    required this.unavailableLabel,
    required this.popularLabel,
  });

  @override
  Widget build(BuildContext context) {
    final border = isBestValue
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final bg = isBestValue
        ? AppColors.primary.withValues(alpha: 0.08)
        : (isDark ? AppColors.darkCard : AppColors.lightCard);

    return GestureDetector(
      onTap: isLoading || unavailable ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: border,
            width: isBestValue ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            popularLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (unavailable)
              Text(
                unavailableLabel,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isBestValue
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                  Text(
                    period,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
