import 'package:flutter/material.dart';
// Certifique-se de ter as dependências 'firebase_core', 'firebase_auth', e 'cloud_firestore' no seu pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillcampus/model/userprofile_model.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 3. Implementação da função de busca de dados
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<UserProfile> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = _fetchUserData();
  }

  Future<UserProfile> _fetchUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      // Retorna um perfil de convidado/default se não houver usuário autenticado
      return UserProfile(
        name: 'Convidado',
        email: 'Faça login para ver seu perfil',
        level: 0,
        totalPoints: 0,
        quizzesPlayed: 0,
        accuracy: '0%',
        bestStreak: 0,
        avgScore: 0,
        avgTimePerQuestion: '0s',
        achievements: [],
        history: [],
      );
    }

    try {
      // Assume que os documentos de perfil estão na coleção 'users' e o ID é o UID do usuário
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromFirestore(doc.data()!);
      } else {
        // Retorna dados default se o documento não existir (usuário novo, por exemplo)
        return UserProfile(
          name: user.displayName ?? 'Novo Usuário',
          email: user.email ?? 'email@naoencontrado.com',
          level: 1,
          totalPoints: 0,
          quizzesPlayed: 0,
          accuracy: '0%',
          bestStreak: 0,
          avgScore: 0,
          avgTimePerQuestion: '0s',
          achievements: [],
          history: [],
        );
      }
    } catch (e) {
      // Trata erros de busca (permissão, rede, etc.)
      debugPrint("Erro ao buscar dados do Firebase: $e");
      throw Exception("Não foi possível carregar os dados do perfil.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FF),
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      // 4. Usa FutureBuilder para lidar com o estado assíncrono
      body: FutureBuilder<UserProfile>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Erro: ${snapshot.error}',
                    textAlign: TextAlign.center));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado de perfil encontrado.'));
          }

          // Se os dados estiverem disponíveis
          final userProfile = snapshot.data!;

          // Simulação de dados de acertos/total (se não vierem do Firebase)
          final totalQuestions = userProfile.quizzesPlayed * 10; // Exemplo
          final correctAnswers = (userProfile.quizzesPlayed * 7.5).round(); // Exemplo

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Perfil do Usuário ---
                _buildUserProfileSection(userProfile),

                const SizedBox(height: 20),

                // --- Estatísticas Gerais ---
                const Text(
                  "Estatísticas Gerais",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatsSection(
                    userProfile, correctAnswers, totalQuestions),

                const SizedBox(height: 20),

                // --- Conquistas ---
                const Text(
                  "Conquistas",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAchievementsSection(userProfile.achievements),

                const SizedBox(height: 20),

                // --- Histórico Recente ---
                const Text(
                  "Histórico Recente",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHistorySection(userProfile.history),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Seção: Perfil do Usuário ---
  Widget _buildUserProfileSection(UserProfile profile) {
    final initials = profile.name.isNotEmpty
        ? profile.name.split(' ').map((e) => e[0]).join().substring(0, profile.name.split(' ').length > 1 ? 2 : 1).toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFD9D9FF),
                child: Text(
                  initials,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _tagBox("Nível ${profile.level}",
                            const Color(0xFFEAE8FF), const Color(0xFF4A3AFF)),
                        const SizedBox(width: 6),
                        _tagBox("${profile.totalPoints} pts",
                            const Color(0xFFFFF0C2), const Color(0xFFCE9B00)),
                      ],
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implementar navegação para edição
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implementar lógica de compartilhamento
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text("Compartilhar Perfil"),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Seção: Estatísticas ---
  Widget _buildStatsSection(UserProfile profile, int correct, int total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBox("${profile.quizzesPlayed}", "Quizzes Jogados", Colors.indigo),
              _statBox("${profile.totalPoints}", "Pontos Totais", Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBox(profile.accuracy, "Precisão", Colors.blue),
              _statBox("${profile.bestStreak}", "Melhor Sequência", Colors.purple),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Pontuação Média: ${profile.avgScore} pts\nTempo Médio por Pergunta: ${profile.avgTimePerQuestion}\nAcertos/Total: $correct/$total",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }

  // --- Seção: Conquistas ---
  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements) {
    // Usamos os dados reais do Firebase para montar as caixas, caindo para mock se vazias
    final mockAchievements = [
      {'icon': "🏆", 'title': "Primeira Vitória", 'desc': "Vença seu primeiro quiz", 'isCompleted': true},
      {'icon': "⚡", 'title': "Velocista", 'desc': "Responda em menos de 10s", 'isCompleted': true},
      {'icon': "🎯", 'title': "Precisão Total", 'desc': "Acerte todas as perguntas", 'isCompleted': false},
      {'icon': "⭐", 'title': "Veterano", 'desc': "Complete 50 quizzes", 'isCompleted': false},
      {'icon': "👑", 'title': "Dominador", 'desc': "Vença 10 quizzes seguidos", 'isCompleted': false},
      {'icon': "📘", 'title': "Conhecimento", 'desc': "Acerte 500 perguntas", 'isCompleted': false},
    ];

    final dataToShow = achievements.isEmpty ? mockAchievements : achievements;

    // Converte a lista em pares para exibição em linhas de 2
    List<Widget> rows = [];
    for (int i = 0; i < dataToShow.length; i += 2) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _achievementBox(
              dataToShow[i]['icon'] ?? '',
              dataToShow[i]['title'] ?? '',
              dataToShow[i]['desc'] ?? '',
              (dataToShow[i]['isCompleted'] ?? false)
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
            ),
            if (i + 1 < dataToShow.length)
              _achievementBox(
                dataToShow[i + 1]['icon'] ?? '',
                dataToShow[i + 1]['title'] ?? '',
                dataToShow[i + 1]['desc'] ?? '',
                (dataToShow[i + 1]['isCompleted'] ?? false)
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
              )
            else
              const Spacer(flex: 1), // Para manter o alinhamento
          ],
        ),
      );
      if (i + 2 < dataToShow.length) rows.add(const SizedBox(height: 12));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rows,
      ),
    );
  }


  // --- Seção: Histórico Recente ---
  Widget _buildHistorySection(List<Map<String, dynamic>> history) {
    // Mapeia os dados do histórico para _historyTile
    if (history.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const ListTile(
          title: Text("Nenhum quiz jogado recentemente."),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: history.map((item) {
          return _historyTile(
            item['title'] ?? 'Quiz Desconhecido',
            item['tag'] ?? 'Geral',
            item['points'] != null ? "${item['points']} pts" : "0 pts",
            item['position'] != null ? "#${item['position']}" : "#?",
          );
        }).toList(),
      ),
    );
  }


  // --- Widgets auxiliares ---

  // Auxiliar para as tags (Nível, Pontos)
  Widget _tagBox(String text, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Auxiliar para as caixas de estatísticas
  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Auxiliar para as caixas de conquista
  Widget _achievementBox(
      String icon, String title, String desc, Color bgColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        height: 70,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            Text(desc,
                style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Auxiliar para os itens do histórico
  Widget _historyTile(
      String title, String tag, String points, String position) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(tag, style: const TextStyle(color: Colors.black54)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(points,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(position, style: const TextStyle(color: Colors.amber)),
        ],
      ),
    );
  }
}
