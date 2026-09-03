import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/screens/category_jokes_screen.dart';
import 'package:komiko/screens/home_screen.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/utils/joke_categories.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // (category key, icon, bgColor)
    final items = [
      (JokeCategories.animals,      Icons.pets_rounded,               AppColors.catAnimaux),
      (JokeCategories.belgians,     Icons.public_rounded,              AppColors.catBelges),
      (JokeCategories.blondes,      Icons.face_rounded,                AppColors.catBlondes),
      (JokeCategories.computer,     Icons.computer_rounded,            AppColors.catInformatique),
      (JokeCategories.medicine,     Icons.medical_services_rounded,    AppColors.catMedecine),
      (JokeCategories.sport,        Icons.sports_soccer_rounded,       AppColors.catSport),
      (JokeCategories.toto,         Icons.sentiment_very_satisfied,    AppColors.catToto),
      (JokeCategories.management,   Icons.business_center_rounded,     AppColors.catManagement),
      (JokeCategories.general,      Icons.tag_faces,                   AppColors.catGeneral),
      (JokeCategories.other,        Icons.more_horiz_rounded,          AppColors.catOther),
    ];

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
          AppAssets.komikoLogoForDark(isDark),
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
                langCode: langCode(context),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header in body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.exploreStyles,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.categoriesSubtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = items[index];
                  return _CategoryCard(
                    categoryKey: item.$1,
                    icon: item.$2,
                    iconBg: item.$3,
                    label: JokeCategories.getLocalizedName(
                        item.$1, AppLocalizations.of(context)!),
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryJokesScreen(category: item.$1),
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  String langCode(BuildContext context) =>
      Localizations.localeOf(context).languageCode;
}

class _CategoryCard extends StatelessWidget {
  final String categoryKey;
  final IconData icon;
  final Color iconBg;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.categoryKey,
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(color: AppColors.darkBorder)
              : Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

