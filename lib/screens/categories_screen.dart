import 'package:flutter/material.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'propose_joke_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exploreStyles),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCategoryCard(context, Icons.pets, l10n.catAnimals),
          _buildCategoryCard(context, Icons.public, l10n.catBelgians),
          _buildCategoryCard(context, Icons.face, l10n.catBlondes),
          _buildCategoryCard(context, Icons.computer, l10n.catComputer),
          _buildCategoryCard(context, Icons.medical_services, l10n.catMedicine),
          _buildCategoryCard(context, Icons.sports_soccer, l10n.catSport),
          _buildCategoryCard(context, Icons.sentiment_very_satisfied, l10n.catToto),
          _buildCategoryCard(context, Icons.add, l10n.propose, isAction: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProposeJokeScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String title, {bool isAction = false, VoidCallback? onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: isAction ? Colors.grey : Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
