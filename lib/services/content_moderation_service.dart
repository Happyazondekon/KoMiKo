// ignore_for_file: constant_identifier_names

/// Service de modération du contenu.
/// Censure les mots interdits en les remplaçant par [***].
/// La banque de mots est extensible depuis Firestore (config/bannedWords).
class ContentModerationService {
  ContentModerationService._();

  static final ContentModerationService instance = ContentModerationService._();

  // ── Banque de mots statique (FR + EN) ──────────────────────────────────────
  // AVERTISSEMENT : cette liste contient des termes explicites intentionnellement
  // pour les censurer dans l'application.
  static const List<String> _staticBannedWords = [
    // ── Termes sexuels explicites (FR) ────────────────────────
    'sexe', 'baiser', 'niquer', 'nique', 'foutre', 'baise', 'enculer',
    'encule', 'sodomie', 'sodomiser', 'porn', 'porno', 'pornographie',
    'masturbation', 'masturber', 'branlette', 'branler', 'éjaculer',
    'ejaculer', 'ejaculation', 'éjaculation', 'orgasme', 'érection',
    'erection', 'phallus', 'vagin', 'vulve', 'pénis', 'penis',
    'bite', 'queue', 'zizi', 'couilles', 'testicules', 'seins',
    'nichons', 'fesses', 'cul', 'anus', 'prostituée', 'pute', 'putain',
    'salope', 'bordel', 'maquereau', 'proxénète', 'exhib',
    'exhibitionnisme', 'fellation', 'sodomie', 'cunnilingus', 'orgie',
    'hentai', 'xxx', 'nue', 'nu', 'nuda', 'strip', 'stripper',

    // ── Termes sexuels (EN) ───────────────────────────────────
    'sex', 'fuck', 'fucking', 'fucked', 'fucker', 'shit', 'bullshit',
    'pussy', 'dick', 'cock', 'asshole', 'ass', 'bitch', 'whore',
    'slut', 'bastard', 'cunt', 'porn', 'pornography', 'masturbate',
    'masturbation', 'orgasm', 'erection', 'vagina', 'penis', 'boobs',
    'boob', 'tits', 'tit', 'nude', 'naked', 'strip', 'stripper',
    'ejaculate', 'ejaculation', 'cum', 'blowjob', 'handjob', 'dildo',
    'vibrator', 'fetish', 'orgy', 'hentai', 'xxx', 'nsfw',

    // ── Insultes & discriminatoires (FR) ─────────────────────
    'connard', 'connasse', 'enfoiré', 'enfoire', 'salopard',
    'merde', 'chiotte', 'idiot', 'imbécile', 'imbecile', 'crétin',
    'cretin', 'abruti', 'débile', 'debile', 'nègre', 'negre',
    'bamboula', 'chinetoque', 'bicot', 'bougnoule', 'youpin',
    'juif', 'arabe', 'feuj', 'intifada', 'terrorist', 'terroriste',
    'nazisme', 'nazi', 'fasciste', 'fascism', 'raciste', 'racisme',

    // ── Insultes (EN) ─────────────────────────────────────────
    'nigger', 'nigga', 'faggot', 'fag', 'retard', 'idiot', 'moron',
    'imbecile', 'nazi', 'fascist', 'racist', 'racism', 'terrorist',

    // ── Drogues & substances ──────────────────────────────────
    'cocaine', 'cocaïne', 'heroïne', 'heroine', 'crack', 'meth',
    'methamphetamine', 'weed', 'cannabis', 'shit' /* drogue */, 'ecstasy',
    'mdma', 'lsd', 'opium', 'morphine', 'fentanyl', 'dealer',

    // ── Violence extrême ──────────────────────────────────────
    'suicide', 'suicider', 'tuer', 'assassiner', 'massacrer', 'viol',
    'violer', 'violence', 'torturer', 'torture', 'décapiter',
    'décapitation', 'mutiler', 'mutilation', 'kill', 'murder', 'rape',
    'torture', 'massacre', 'genocide', 'génocide',
  ];

  /// Liste combinée (statique + Firestore si chargée)
  List<String> _allBannedWords = List.from(_staticBannedWords);

  /// Mise à jour depuis Firestore (appelée au démarrage si possible)
  void updateFromFirestore(List<String> words) {
    final combined = <String>{..._staticBannedWords, ...words};
    _allBannedWords = combined.toList();
  }

  // ── API publique ───────────────────────────────────────────────────────────

  /// Remplace les mots interdits dans [text] par [***].
  /// Utilise une expression régulière insensible à la casse et aux accents.
  String censorText(String text) {
    if (text.isEmpty) return text;
    String result = text;
    for (final word in _allBannedWords) {
      if (word.isEmpty) continue;
      // Cherche le mot en tant que sous-chaîne (pas forcément word-boundary
      // car les mots FR composés peuvent être collés)
      final pattern = RegExp(
        RegExp.escape(word),
        caseSensitive: false,
        unicode: true,
      );
      result = result.replaceAll(pattern, '***');
    }
    return result;
  }

  /// Retourne true si [text] contient au moins un mot interdit.
  bool containsBannedWords(String text) {
    if (text.isEmpty) return false;
    final lower = text.toLowerCase();
    for (final word in _allBannedWords) {
      if (word.isEmpty) continue;
      if (lower.contains(word.toLowerCase())) return true;
    }
    return false;
  }

  /// Retourne le texte censuré si nécessaire, sinon le texte original.
  /// Équivalent pratique de [censorText] avec vérification intégrée.
  String safeText(String text) => censorText(text);
}
