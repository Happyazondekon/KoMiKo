import 'package:flutter/material.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:komiko/widgets/joke_card.dart';

class CategoryJokesScreen extends StatelessWidget {
  /// The canonical Firestore category key (e.g. 'Animaux').
  final String category;

  const CategoryJokesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = JokeCategories.getLocalizedName(category, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
      ),
      body: StreamBuilder<List<Joke>>(
        stream: JokeService().getJokesByCategory(category),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${l10n.error}: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jokes = snapshot.data ?? [];

          if (jokes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sentiment_dissatisfied,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noJokesInCategory,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: jokes.length,
            itemBuilder: (context, index) => JokeCard(joke: jokes[index]),
          );
        },
      ),
    );
  }
}
