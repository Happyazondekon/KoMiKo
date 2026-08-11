import 'package:flutter/material.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/utils/joke_categories.dart';
import 'package:provider/provider.dart';

class ProposeJokeScreen extends StatefulWidget {
  const ProposeJokeScreen({super.key});

  @override
  State<ProposeJokeScreen> createState() => _ProposeJokeScreenState();
}

class _ProposeJokeScreenState extends State<ProposeJokeScreen> {
  final _contentController = TextEditingController();
  final _punchlineController = TextEditingController();
  // Stores the canonical Firestore category key (not the localized label)
  String _selectedCategory = JokeCategories.general;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _punchlineController.dispose();
    super.dispose();
  }

  Future<void> _submitJoke() async {
    final l10n = AppLocalizations.of(context)!;
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enterJokeContent)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = context.read<UserService>().currentUser!;
      final joke = Joke(
        id: '',
        contentFr: _contentController.text.trim(),
        punchlineFr: _punchlineController.text.trim().isEmpty
            ? null
            : _punchlineController.text.trim(),
        category: _selectedCategory,
        authorName: user.username ?? l10n.anonymous,
        authorId: user.uid,
        authorAvatarUrl: user.avatarUrl,
        isAuthorVerified: user.isVerified,
        createdAt: DateTime.now(),
      );

      await JokeService().addJoke(joke);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.jokePublished)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proposeJoke)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.proposeJoke,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.category,
                border: const OutlineInputBorder(),
              ),
              items: JokeCategories.all
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(
                          JokeCategories.getLocalizedName(key, l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.jokeContent,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _punchlineController,
              decoration: InputDecoration(
                labelText: l10n.punchline,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitJoke,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(l10n.publish),
            ),
          ],
        ),
      ),
    );
  }
}
