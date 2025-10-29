import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillcampus/model/quiz_model.dart'; 

class SalaQuizPage extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final String quizId;

  const SalaQuizPage({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.quizId,
  });

  @override
  State<SalaQuizPage> createState() => _SalaQuizPageState();
}

class _SalaQuizPageState extends State<SalaQuizPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  QuizModel? _quizDetails;

  @override
  void initState() {
    super.initState();
    _fetchQuizDetails(widget.quizId);
  }

  // Função para buscar os detalhes do quiz
  Future<void> _fetchQuizDetails(String quizId) async {
    try {
      final doc = await _db.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        setState(() {
          _quizDetails = QuizModel.fromFirestore(doc);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar detalhes do quiz: $e");
    }
  }

  // --- LÓGICA DE CONTROLE DO HOST ---

  // Altera o status da sala para 'playing' e inicializa o índice da pergunta.
  Future<void> _startQuiz() async {
    try {
      await _db.collection('rooms').doc(widget.roomId).update({
        'status': 'playing', 
        'currentQuestionIndex': 0,
      });
    } catch (e) {
      debugPrint("Erro ao iniciar quiz: $e");
    }
  }

  // Avança para a próxima pergunta ou finaliza o quiz. (Apenas Host)
  Future<void> _nextQuestion(int currentIndex, int totalQuestions) async {
    if (currentIndex < totalQuestions - 1) {
      try {
        await _db.collection('rooms').doc(widget.roomId).update({
          'currentQuestionIndex': currentIndex + 1,
        });
      } catch (e) {
        debugPrint("Erro ao avançar pergunta: $e");
      }
    } else {
      // Fim do Quiz
      try {
        await _db.collection('rooms').doc(widget.roomId).update({
          'status': 'finished',
          'currentQuestionIndex': totalQuestions, // Indica que o quiz terminou
        });
      } catch (e) {
        debugPrint("Erro ao finalizar quiz: $e");
      }
    }
  }

  // Função para apagar a sala (a ser chamada no fim do quiz pelo Host)
  Future<void> _deleteRoom() async {
    try {
      await _db.collection('rooms').doc(widget.roomId).delete();
      if (mounted) {
        // Retorna para a tela inicial (InicioPage) após a exclusão
        Navigator.of(context).pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sala de Quiz encerrada e excluída.")),
        );
      }
    } catch (e) {
      debugPrint("Erro ao excluir sala: $e");
    }
  }
  // -----------------------------------

  @override
  Widget build(BuildContext context) {
    // 1. Stream para o estado da sala em tempo real
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('rooms').doc(widget.roomId).snapshots(),
      builder: (context, roomSnapshot) {
        // Lógica de carregamento e erro
        if (roomSnapshot.connectionState == ConnectionState.waiting || _quizDetails == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (roomSnapshot.hasError || !roomSnapshot.data!.exists) {
          // Se a sala não existir mais (excluída), navega de volta
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("O Host encerrou o Quiz.")),
              );
            }
          });
          return const SizedBox.shrink(); // Widget vazio enquanto navega
        }
        
        final roomData = roomSnapshot.data!.data() as Map<String, dynamic>;
        final participantsMap = roomData['participants'] as Map<String, dynamic>? ?? {};
        final isHost = participantsMap[widget.currentUserId]?['host'] == true;
        final roomStatus = roomData['status'] as String? ?? 'waiting';
        final currentQuestionIndex = roomData['currentQuestionIndex'] as int? ?? 0;
        final quiz = _quizDetails!;
        
        // 2. Decide qual tela mostrar com base no status
        if (roomStatus == 'waiting') {
          return _buildWaitingScreen(isHost, quiz.title, participantsMap);
        } else if (roomStatus == 'playing') {
          // 3. Garante que o índice da pergunta é válido
          if (currentQuestionIndex >= quiz.questions.length) {
             return _buildFinishedScreen(isHost);
          }
          final currentQuestion = quiz.questions[currentQuestionIndex];
          return _buildQuizContent(
            quiz: quiz,
            currentQuestion: currentQuestion,
            currentIndex: currentQuestionIndex,
            isHost: isHost,
            participantsMap: participantsMap,
          );
        } else if (roomStatus == 'finished') {
          return _buildFinishedScreen(isHost);
        }
        
        // Default (não deve acontecer)
        return const Scaffold(body: Center(child: Text("Status de sala desconhecido.")));
      },
    );
  }

  // --- TELAS POR ESTADO ---

  // Tela de espera/lobby (agora usada apenas para o Host iniciar)
  Widget _buildWaitingScreen(bool isHost, String quizTitle, Map<String, dynamic> participantsMap) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurando Quiz: $quizTitle'),
        backgroundColor: const Color(0xFF4A3AFF),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF1F4FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Código da Sala: ${widget.roomId}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              _buildParticipantsStatus(participantsMap),
              const SizedBox(height: 40),
              if (isHost) ...[
                const Text(
                  'Outros jogadores podem se juntar usando o código acima.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _startQuiz,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text('INICIAR QUIZ AGORA', style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else ...[
                const Text(
                  'Aguardando o Host iniciar o quiz...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A3AFF)),
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(color: Color(0xFF4A3AFF)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Tela de conteúdo do Quiz (Perguntas)
  Widget _buildQuizContent({
    required QuizModel quiz,
    required QuestionModel currentQuestion,
    required int currentIndex,
    required bool isHost,
    required Map<String, dynamic> participantsMap,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${quiz.title} - Pergunta ${currentIndex + 1}'),
        backgroundColor: const Color(0xFF4A3AFF),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF1F4FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Pergunta Atual: ${currentIndex + 1} / ${quiz.questions.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Card da Pergunta
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                currentQuestion.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            
            const Text("Opções de Resposta:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            
            // Lista de Opções
            ...currentQuestion.options.asMap().entries.map((entry) {
              final optionText = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // Lógica futura: _submitAnswer(optionText, entry.key);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Respondeu: ${optionText}")),
                    );
                  },
                  child: Text(
                    optionText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),
            
            // Botão de Avanço (Apenas Host)
            if (isHost)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _nextQuestion(currentIndex, quiz.questions.length),
                  icon: Icon(currentIndex < quiz.questions.length - 1 ? Icons.skip_next : Icons.done_all, color: Colors.white),
                  label: Text(
                    currentIndex < quiz.questions.length - 1 ? 'PRÓXIMA PERGUNTA' : 'FINALIZAR QUIZ',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

            const SizedBox(height: 30),
            
            // Status dos Participantes no Jogo
            _buildParticipantsStatus(participantsMap),
          ],
        ),
      ),
    );
  }

  // Tela Final do Quiz
  Widget _buildFinishedScreen(bool isHost) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Encerrado'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF1F4FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                "Fim do Quiz!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Text(
                "Aguardando os resultados finais...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              if (isHost)
                ElevatedButton.icon(
                  onPressed: _deleteRoom, // Host APAGA A SALA APÓS O FIM
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('EXCLUIR SALA', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para exibir o status dos participantes (usado em todas as telas)
  Widget _buildParticipantsStatus(Map<String, dynamic> participants) {
    final List<Map<String, dynamic>> participantes = participants.entries.map((entry) {
        final data = entry.value as Map<String, dynamic>;
        data['id'] = entry.key;
        return data;
      }).toList();
      
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status dos Jogadores', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...participantes.map((p) {
            final isCurrentUser = p['id'] == widget.currentUserId;
            final isHost = p['host'] == true;
            final status = p['status'] as String? ?? 'aguardando'; 
            String displayStatus = status.capitalize();

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: isHost ? Colors.orange : (isCurrentUser ? Colors.blue : Colors.grey),
                    child: isHost ? const Icon(Icons.star, size: 10, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p['name'] + (isCurrentUser ? ' (Você)' : ''),
                    style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal),
                  ),
                  const Spacer(),
                  Text(displayStatus, style: TextStyle(color: status == 'pronto' || status == 'playing' ? Colors.green : Colors.grey, fontSize: 12)), 
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
