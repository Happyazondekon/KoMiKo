import 'package:flutter/material.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:intl/intl.dart';
import 'package:komiko/screens/joke_detail_screen.dart';
import 'package:komiko/services/auth_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';

class JokeCard extends StatelessWidget {
  final Joke joke;

  const JokeCard({super.key, required this.joke});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid ?? '';
    final isLiked = joke.likedBy.contains(userId);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => JokeDetailScreen(joke: joke)));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    child: Icon(Icons.person, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        joke.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${DateFormat.yMMMd().format(joke.createdAt)} • ${joke.category}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    onPressed: () {
                      Share.share("${joke.content}\n\n${joke.punchline ?? ''}\n\nPartagé via Komiko");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                joke.content,
                style: const TextStyle(fontSize: 16),
              ),
              if (joke.punchline != null) ...[
                const SizedBox(height: 12),
                Text(
                  joke.punchline!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStat(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    joke.likesCount.toString(),
                    isLiked ? Colors.red : Colors.pink,
                    label: l10n.like,
                    onTap: () {
                      if (userId.isNotEmpty) {
                        JokeService().likeJoke(joke.id, userId);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    Icons.chat_bubble_outline,
                    joke.commentsCount.toString(),
                    Colors.blue,
                    label: l10n.comments,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, Color color, {required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
