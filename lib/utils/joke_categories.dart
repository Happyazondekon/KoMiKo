import 'package:komiko/generated/gen_l10n/app_localizations.dart';

// ── Time-ago helper ──────────────────────────────────────────────────────────

/// Returns a human-readable relative time string localised to [langCode].
String timeAgo(DateTime dt, String langCode) {
  final diff = DateTime.now().difference(dt);
  if (langCode == 'fr') {
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return 'il y a ${(diff.inDays / 7).floor()}sem';
  } else {
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

// ── Category definitions ─────────────────────────────────────────────────────

/// Canonical category identifiers stored in Firestore.
/// Always use these constants for Firestore reads/writes.
class JokeCategories {
  JokeCategories._();

  static const String general = 'Général';
  static const String animals = 'Animaux';
  static const String belgians = 'Belges';
  static const String blondes = 'Blondes';
  static const String computer = 'Informatique';
  static const String medicine = 'Médecine';
  static const String sport = 'Sport';
  static const String toto = 'Toto';
  static const String management = 'Management';
  static const String other = 'Autre';

  static const List<String> all = [
    general,
    animals,
    belgians,
    blondes,
    computer,
    medicine,
    sport,
    toto,
    management,
    other,
  ];

  /// Returns the localized display name for a Firestore category key.
  static String getLocalizedName(String category, AppLocalizations l10n) {
    switch (category) {
      case general:
        return l10n.catGeneral;
      case animals:
        return l10n.catAnimals;
      case belgians:
        return l10n.catBelgians;
      case blondes:
        return l10n.catBlondes;
      case computer:
        return l10n.catComputer;
      case medicine:
        return l10n.catMedicine;
      case sport:
        return l10n.catSport;
      case toto:
        return l10n.catToto;
      case management:
        return l10n.catManagement;
      default:
        return l10n.catOther;
    }
  }
}
