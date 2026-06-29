import 'package:flutter/material.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/widgets/joke_card.dart';
import 'package:komiko/screens/joke_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jokeService = JokeService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Daily Joke Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyJoke.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Pourquoi les plongeurs plongent-ils toujours en arrière et jamais en avant ?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Parce que sinon ils tombent encore dans le bateau.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Best Jokes Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.bestJokes,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(l10n.seeAll),
                  ),
                ],
              ),
            ),
          ),
          // Best Jokes List
          StreamBuilder<List<Joke>>(
            stream: jokeService.bestJokesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('${l10n.error}: ${snapshot.error}')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final jokes = snapshot.data ?? [];
              
              if (jokes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text(l10n.noJokes)),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => JokeCard(joke: jokes[index]),
                  childCount: jokes.length,
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Get all jokes and pick one randomly
                  jokeService.jokesStream.first.then((jokes) {
                    if (jokes.isNotEmpty) {
                      final randomJoke = (jokes..shuffle()).first;
                      if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => JokeDetailScreen(joke: randomJoke)));
                      }
                    }
                  });
                },
                icon: const Icon(Icons.casino_outlined),
                label: Text(l10n.randomJoke),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  l10n.loadingMore,
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
