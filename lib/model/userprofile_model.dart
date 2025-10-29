
class UserProfile {
  final String name;
  final String email;
  final int level;
  final int totalPoints;
  final int quizzesPlayed;
  final String accuracy;
  final int bestStreak;
  final int avgScore;
  final String avgTimePerQuestion;
  final List<Map<String, dynamic>> achievements;
  final List<Map<String, dynamic>> history;

  UserProfile({
    required this.name,
    required this.email,
    required this.level,
    required this.totalPoints,
    required this.quizzesPlayed,
    required this.accuracy,
    required this.bestStreak,
    required this.avgScore,
    required this.avgTimePerQuestion,
    required this.achievements,
    required this.history,
  });

  // Construtor a partir do DocumentSnapshot do Firestore
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] ?? 'Usuário Desconhecido',
      email: data['email'] ?? 'email@naoencontrado.com',
      level: data['level'] ?? 0,
      totalPoints: data['totalPoints'] ?? 0,
      quizzesPlayed: data['quizzesPlayed'] ?? 0,
      accuracy: data['accuracy'] ?? '0%',
      bestStreak: data['bestStreak'] ?? 0,
      avgScore: data['avgScore'] ?? 0,
      avgTimePerQuestion: data['avgTimePerQuestion'] ?? '0s',
      achievements: List<Map<String, dynamic>>.from(data['achievements'] ?? []),
      history: List<Map<String, dynamic>>.from(data['history'] ?? []),
    );
  }
}