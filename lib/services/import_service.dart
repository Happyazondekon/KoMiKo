import 'package:komiko/models/joke_model.dart';
import 'package:komiko/services/joke_service.dart';

class ImportService {
  static final List<Map<String, String>> _rawJokes = [
    {
      "category": "Animaux",
      "content": "Pourquoi les plongeurs plongent-ils toujours en arrière et jamais en avant ?",
      "punchline": "Parce que sinon ils tombent encore dans le bateau."
    },
    {
      "category": "Informatique",
      "content": "Un informaticien à la plage. Sa femme lui dit : 'Chéri, tu peux aller te baigner, l'eau est excellente !'",
      "punchline": "L'informaticien répond : 'Attends, je vérifie d'abord si la connexion est stable.'"
    },
    {
      "category": "Management",
      "content": "Un monsieur avait un gros matou qui engrossait toutes les chattes du voisinage. Il le fait opérer. Un soir, il voit tous les matous du quartier autour de son chat.",
      "punchline": "Le monsieur dit : 'Quand t'es plus bon à rien, tu deviens consultant !'"
    },
    {
      "category": "Toto",
      "content": "Le professeur demande à Toto : 'Toto, cite-moi un mammifère qui n'a pas de dents.'",
      "punchline": "Toto réfléchit et répond : 'Ma grand-mère ?'"
    },
    {
      "category": "Blondes",
      "content": "Pourquoi les blondes mettent-elles du sucre sous leur oreiller ?",
      "punchline": "Pour faire de beaux rêves."
    },
    {
      "category": "Belges",
      "content": "Pourquoi les Belges nagent-ils toujours au fond de la piscine ?",
      "punchline": "Parce qu'au fond, ils sont pas si cons."
    },
    {
      "category": "Général",
      "content": "Qu'est-ce qui est jaune et qui court très vite ?",
      "punchline": "Un citron pressé !"
    },
    {
      "category": "Médecine",
      "content": "J'ai dit à mon docteur que je m'étais cassé le bras à deux endroits.",
      "punchline": "Il m'a dit d'arrêter d'aller à ces endroits."
    }
  ];

  static Future<void> importInitialJokes() async {
    final jokeService = JokeService();
    for (var raw in _rawJokes) {
      final joke = Joke(
        id: '',
        content: raw['content']!,
        punchline: raw['punchline'],
        category: raw['category']!,
        authorName: "Komiko Bot",
        authorId: "system",
        createdAt: DateTime.now(),
        likesCount: (raw['content']!.length % 100) * 10, // Just for fun
      );
      await jokeService.addJoke(joke);
    }
  }
}
