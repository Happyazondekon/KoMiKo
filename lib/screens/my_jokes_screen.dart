import 'package:flutter/material.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/screens/joke_detail_screen.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:komiko/widgets/joke_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyJokesScreen extends StatelessWidget {
  const MyJokesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = context.read<UserService>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myJokes),
      ),
      body: StreamBuilder<List<Joke>>(
        stream: JokeService().getUserJokes(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
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
                    Icon(Icons.edit_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMyJokes,
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
            itemBuilder: (context, index) {
              final joke = jokes[index];
              final langCode = Localizations.localeOf(context).languageCode;
              return _MyJokeTile(
                joke: joke,
                langCode: langCode,
                l10n: l10n,
              );
            },
          );
        },
      ),
    );
  }
}

class _MyJokeTile extends StatelessWidget {
  final Joke joke;
  final String langCode;
  final AppLocalizations l10n;

  const _MyJokeTile({
    required this.joke,
    required this.langCode,
    required this.l10n,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteJoke),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await JokeService().deleteJoke(joke.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.jokeDeleted)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = joke.localizedContent(langCode);
    final punchline = joke.localizedPunchline(langCode);
    final currentUser = context.watch<UserService>().currentUser;
    final isVerified = joke.isAuthorVerified || (currentUser?.effectiveIsVerified ?? false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JokeDetailScreen(joke: joke)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AuthorAvatar(
                    url: joke.authorAvatarUrl,
                    name: joke.authorName,
                    radius: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              joke.authorName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  color: Colors.amber, size: 16),
                            ],
                          ],
                        ),
                        Text(
                          "${DateFormat.yMMMd().format(joke.createdAt)} • ${JokeCategories.getLocalizedName(joke.category, l10n)}",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: l10n.deleteJoke,
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(content, style: const TextStyle(fontSize: 15)),
              if (punchline != null && punchline.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  punchline,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.favorite_border, size: 16, color: Colors.pink),
                  const SizedBox(width: 4),
                  Text('${joke.likesCount}',
                      style: const TextStyle(color: Colors.pink)),
                  const SizedBox(width: 16),
                  Icon(Icons.chat_bubble_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('${joke.commentsCount}',
                      style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
