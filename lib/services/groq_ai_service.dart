import 'dart:convert';
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:komiko/models/joke_model.dart';

/// Service gérant les fonctionnalités d'Intelligence Artificielle de Komiko
/// propulsé par l'API Groq (GPT OSS 20B / 120B).
class GroqAiService {
  /// Clé API Groq sécurisée : récupérée en priorité depuis --dart-define=GROQ_API_KEY
  /// ou depuis Firebase Remote Config ('groq_api_key'), jamais committée en dur.
  static String get _apiKey {
    const envKey = String.fromEnvironment('GROQ_API_KEY');
    if (envKey.isNotEmpty) return envKey;

    try {
      final remoteKey = FirebaseRemoteConfig.instance.getString('groq_api_key');
      if (remoteKey.isNotEmpty) return remoteKey;
    } catch (_) {}

    return '';
  }

  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  
  // Modèle GPT OSS 20B officiel disponible sur le compte Groq de Komiko
  static const String _model = 'openai/gpt-oss-20b';
  static const String _fallbackModel = 'openai/gpt-oss-120b';

  static final GroqAiService instance = GroqAiService._internal();
  GroqAiService._internal();

  /// Envoie un prompt à Groq et retourne la réponse texte
  Future<String?> _chatCompletion({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.7,
    int maxTokens = 800,
  }) async {
    // Essayer avec le modèle principal GPT OSS 20B puis fallback sur GPT OSS 120B
    final result = await _executeRequest(
      model: _model,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );
    if (result != null && result.isNotEmpty) return result;

    return await _executeRequest(
      model: _fallbackModel,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  Future<String?> _executeRequest({
    required String model,
    required String systemPrompt,
    required String userPrompt,
    required double temperature,
    required int maxTokens,
  }) async {
    final key = _apiKey;
    if (key.isEmpty) {
      debugPrint('[GroqAiService] Clé API Groq non configurée (GROQ_API_KEY ou RemoteConfig).');
      return null;
    }

    HttpClient? client;
    try {
      client = HttpClient();
      final request = await client.postUrl(Uri.parse(_apiUrl));
      request.headers.set('Authorization', 'Bearer $key');
      request.headers.set('Content-Type', 'application/json; charset=utf-8');

      final body = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      });

      request.write(body);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = json['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          return message?['content']?.toString().trim();
        }
      } else {
        final err = await response.transform(utf8.decoder).join();
        debugPrint('[GroqAiService] Erreur $model ${response.statusCode}: $err');
      }
    } catch (e) {
      debugPrint('[GroqAiService] Exception $model: $e');
    } finally {
      client?.close();
    }
    return null;
  }

  // ── 1. Recommandations personnalisées de blagues ───────────────────────────

  /// Analyse les catégories et styles des blagues que l'utilisateur a likées,
  /// et retourne une liste d'IDs de blagues candidates réordonnées par pertinence IA.
  Future<List<String>> rankJokesForUser({
    required List<Joke> candidateJokes,
    required List<Joke> userLikedJokes,
  }) async {
    if (candidateJokes.isEmpty) return [];
    if (userLikedJokes.isEmpty) {
      // Pas encore d'historique de likes : on conserve l'ordre existant
      return candidateJokes.map((j) => j.id).toList();
    }

    try {
      // Résumer les goûts de l'utilisateur à partir de ses 10 derniers likes
      final sampleLiked = userLikedJokes.take(8).map((j) {
        return '- [Catégorie: ${j.category}] "${j.contentFr.length > 80 ? j.contentFr.substring(0, 80) : j.contentFr}"';
      }).join('\n');

      // Préparer les blagues candidates (IDs + débuts)
      final sampleCandidates = candidateJokes.take(25).map((j) {
        final preview = j.contentFr.replaceAll('\n', ' ');
        final snippet = preview.length > 70 ? preview.substring(0, 70) : preview;
        return '{"id":"${j.id}","cat":"${j.category}","txt":"$snippet"}';
      }).join('\n');

      const systemPrompt =
          'Tu es l\'algorithme de recommandation IA de Komiko, une application de blagues et d\'humour bilingue. '
          'Ta mission est de classer les blagues candidates pour un utilisateur selon ses goûts humoristiques démontrés. '
          'Réponds UNIQUEMENT avec un tableau JSON contenant les IDs dans l\'ordre recommandé, exemple : ["id1", "id2", "id3"].';

      final userPrompt =
          'Voici les blagues que cet utilisateur a aimées récemment :\n$sampleLiked\n\n'
          'Voici les blagues candidates à classer :\n$sampleCandidates\n\n'
          'Donne UNIQUEMENT le tableau JSON des IDs recommandés du plus pertinent au moins pertinent :';

      final response = await _chatCompletion(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        temperature: 0.3,
        maxTokens: 300,
      );

      if (response != null) {
        final startIdx = response.indexOf('[');
        final endIdx = response.lastIndexOf(']');
        if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
          final jsonStr = response.substring(startIdx, endIdx + 1);
          final list = jsonDecode(jsonStr) as List<dynamic>;
          final rankedIds = list.map((e) => e.toString()).toSet();

          // Ordonner : d'abord les IDs recommandés par l'IA, puis le reste
          final result = <String>[];
          for (final id in rankedIds) {
            if (candidateJokes.any((j) => j.id == id)) {
              result.add(id);
            }
          }
          for (final j in candidateJokes) {
            if (!result.contains(j.id)) {
              result.add(j.id);
            }
          }
          return result;
        }
      }
    } catch (e) {
      debugPrint('[GroqAiService] rankJokesForUser error: $e');
    }

    // Fallback par défaut : ordre original
    return candidateJokes.map((j) => j.id).toList();
  }

  // ── 2. Suggestions marketing personnalisées pour Komiko Pro ───────────────

  /// Génère un message marketing court, percutant et plein d'humour
  /// adapté au profil de l'utilisateur pour l'encourager à passer à Komiko Pro.
  Future<String> generateProMarketingPitch({
    required String username,
    required int jokesCount,
    required int totalLikes,
    required String langCode,
  }) async {
    final isFr = langCode == 'fr';

    final systemPrompt = isFr
        ? 'Tu es le rédacteur humoristique de l\'application Komiko. Rédige un pitch marketing ultra-court (1 seule phrase concise), '
          'drôle et percutant en FRANÇAIS UNIQUEMENT pour proposer à un utilisateur de passer à Komiko Pro. '
          'Mets en avant son badge vérifié doré et le boost de visibilité de ses blagues en tête du feed.'
        : 'You are the witty copywriter for the Komiko app. Write a very short (1 punchy sentence) marketing pitch '
          'in ENGLISH ONLY persuading the user to upgrade to Komiko Pro (benefits: verified golden badge, boosted jokes at the top of the feed).';

    final userPrompt = isFr
        ? 'Utilisateur : "$username". Rédige une seule phrase percutante en français pour lui proposer Komiko Pro :'
        : 'User: "$username". Write a single punchy sentence in English offering Komiko Pro:';

    final response = await _chatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      temperature: 0.7,
      maxTokens: 100,
    );

    if (response != null && response.isNotEmpty) {
      // Nettoyer les guillemets éventuels
      return response.replaceAll('"', '').replaceAll('«', '').replaceAll('»', '');
    }

    // Fallback dynamique selon la langue
    return isFr
        ? '✨ Passez à Komiko Pro : obtenez votre badge vérifié et boostez vos blagues en tête du feed !'
        : '✨ Upgrade to Komiko Pro: claim your verified badge and boost your jokes to the top of the feed!';
  }

  // ── 3. Accroche valorisant les créateurs vérifiés & boostés ────────────────

  /// Génère un texte promotionnel d'ambiance pour valoriser les publications en vedette
  Future<String> getFeaturedHeaderCatchphrase(String langCode) async {
    final isFr = langCode == 'fr';
    final response = await _chatCompletion(
      systemPrompt: isFr
          ? 'Tu es le créateur de slogans humoristiques de l\'application Komiko. '
            'Génère une seule phrase courte et drôle (max 10 mots) pour introduire la section des créateurs Pro et posts en vedette.'
          : 'You are the comedic copywriter for Komiko app. Generate a single short, funny phrase (max 10 words) highlighting Pro featured creators.',
      userPrompt: 'Génère la phrase :',
      temperature: 0.7,
      maxTokens: 50,
    );

    if (response != null && response.isNotEmpty) {
      return response.replaceAll('"', '');
    }

    return isFr
        ? 'Les blagues pépites certifiées qui font exploser le compteur ! 🔥'
        : 'Certified comedy gems blowing up the laughter charts! 🔥';
  }

  // ── 4. Assistant créatif IA : Reformulation & Sublimation de blague (Pro) ──

  /// Reformule, punchline ou améliore une blague selon le style sélectionné.
  Future<Map<String, String>?> enhanceJoke({
    required String content,
    String? currentPunchline,
    required String tone,
    required String langCode,
  }) async {
    final isFr = langCode == 'fr';

    String toneInstruction;
    switch (tone) {
      case 'funnier':
        toneInstruction = isFr
            ? 'Rends la blague nettement plus drôle, hilarante et comique avec des détails cocasses.'
            : 'Make the joke significantly funnier, hilarious and comedic with witty details.';
        break;
      case 'punchy':
        toneInstruction = isFr
            ? 'Rends la blague très courte, ultra-percutante et concise (supprime le superflu).'
            : 'Make the joke very short, ultra-punchy and concise (cut the fluff).';
        break;
      case 'punchline':
        toneInstruction = isFr
            ? 'Trouve une chute (punchline) explosive, inattendue et mémorable.'
            : 'Craft an explosive, unexpected, and unforgettable punchline.';
        break;
      case 'clean':
        toneInstruction = isFr
            ? 'Corrige l\'orthographe, la grammaire et sublime le style d\'écriture avec élégance.'
            : 'Fix spelling, grammar, and elevate the writing style smoothly.';
        break;
      case 'crazy':
        toneInstruction = isFr
            ? 'Rends la blague totalement absurde, délirante, décalée et surprenante.'
            : 'Make the joke totally absurd, wacky, unhinged and delightfully surprising.';
        break;
      case 'dark':
        toneInstruction = isFr
            ? 'Transforme la blague en humour noir : grinçant, cynique, politiquement incorrect et piquant, mais toujours spirituel et hilarant.'
            : 'Transform the joke into dark humor: edgy, cynical, biting, but witty and hilarious.';
        break;
      default:
        toneInstruction = isFr
            ? 'Améliore la blague pour la rendre irrésistible.'
            : 'Enhance the joke to make it irresistible.';
    }

    final systemPrompt = isFr
        ? 'Tu es un humoriste et auteur de stand-up professionnel de l\'application Komiko. '
          'Ta mission est de réécrire la blague proposée selon l\'instruction suivante : $toneInstruction. '
          'Respecte la langue de l\'utilisateur (FRANÇAIS). '
          'Réponds UNIQUEMENT avec un objet JSON strict au format exact suivant sans aucun texte autour :\n'
          '{"content": "Le texte de la blague sans la chute", "punchline": "La chute percutante"}'
        : 'You are a professional comedian and stand-up writer for the Komiko app. '
          'Your mission is to rewrite the proposed joke according to this instruction: $toneInstruction. '
          'Keep the user language (ENGLISH). '
          'Respond ONLY with a strict JSON object with this exact format and no surrounding text:\n'
          '{"content": "The joke setup", "punchline": "The punchline"}';

    final userPrompt = (currentPunchline != null && currentPunchline.trim().isNotEmpty)
        ? 'Contenu : "$content"\nChute actuelle : "$currentPunchline"'
        : 'Contenu : "$content"';

    try {
      final response = await _chatCompletion(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        temperature: 0.8,
        maxTokens: 800,
      );

      if (response != null && response.isNotEmpty) {
        String cleaned = response.trim();
        if (cleaned.startsWith('```')) {
          cleaned = cleaned.replaceAll(RegExp(r'^```json\s*|^```\s*|```$'), '').trim();
        }

        final match = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
        if (match != null) {
          try {
            final parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;
            final newContent = parsed['content']?.toString().trim();
            final newPunchline = parsed['punchline']?.toString().trim();

            if (newContent != null && newContent.isNotEmpty) {
              return {
                'content': newContent,
                'punchline': newPunchline ?? '',
              };
            }
          } catch (_) {}
        }

        // Si le décodage JSON direct échoue, utiliser la réponse texte
        return {
          'content': cleaned,
          'punchline': '',
        };
      }
    } catch (e) {
      debugPrint('[GroqAiService] enhanceJoke error: $e');
    }
    return null;
  }
}
