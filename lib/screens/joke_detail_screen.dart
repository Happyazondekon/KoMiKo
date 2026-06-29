import 'package:flutter/material.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/models/comment_model.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class JokeDetailScreen extends StatefulWidget {
  final Joke joke;
  const JokeDetailScreen({super.key, required this.joke});

  @override
  State<JokeDetailScreen> createState() => _JokeDetailScreenState();
}

class _JokeDetailScreenState extends State<JokeDetailScreen> {
  final _commentController = TextEditingController();
  final _jokeService = JokeService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final user = context.read<UserService>().currentUser;
      if (user == null) return;

      final comment = Comment(
        id: '',
        jokeId: widget.joke.id,
        content: content,
        authorName: user.username ?? "Anonymous",
        authorId: user.uid,
        authorAvatarUrl: user.avatarUrl,
        createdAt: DateTime.now(),
      );

      await _jokeService.addComment(comment);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<UserService>().currentUser;
    final isLiked = widget.joke.likedBy.contains(user?.uid ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyJoke),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share("${widget.joke.content}\n\n${widget.joke.punchline ?? ''}\n\nPartagé via Komiko");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(child: Icon(Icons.person)),
                            const SizedBox(width: 12),
                            Text(widget.joke.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Chip(label: Text(widget.joke.category)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.joke.content,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        if (widget.joke.punchline != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            widget.joke.punchline!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              context,
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              l10n.like,
                              color: isLiked ? Colors.red : null,
                              () {
                                if (user != null) {
                                  _jokeService.likeJoke(widget.joke.id, user.uid);
                                }
                              },
                            ),
                            _buildActionButton(context, Icons.chat_bubble_outline, l10n.comments, () {}),
                            _buildActionButton(context, Icons.share_outlined, l10n.share, () {
                              Share.share("${widget.joke.content}\n\n${widget.joke.punchline ?? ''}\n\nPartagé via Komiko");
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l10n.comments, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  StreamBuilder<List<Comment>>(
                    stream: _jokeService.getCommentsStream(widget.joke.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(l10n.noComments, style: const TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (comment.authorAvatarUrl != null && comment.authorAvatarUrl!.startsWith('base64:'))
                                  ? MemoryImage(base64Decode(comment.authorAvatarUrl!.substring(7)))
                                  : null,
                              child: comment.authorAvatarUrl == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(comment.content),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: l10n.addComment,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send, color: Colors.blue),
                    onPressed: _isSubmitting ? null : _submitComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
