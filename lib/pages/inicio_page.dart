import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillcampus/model/quiz_card.dart';
import 'package:skillcampus/model/quiz_model.dart';
import 'package:skillcampus/pages/sala_quiz_page.dart';
import 'create_quiz_page.dart'; // Importação da nova tela de criação

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();

  // --- VARIÁVEIS DE USUÁRIO ÚNICO POR SESSÃO ---
  late final String currentUserId;
  late final String currentUserName;

  @override
  void initState() {
    super.initState();
    // GERAÇÃO DE ID E NOME ÚNICOS para simular um login diferente em cada instância
    final uniqueId = DateTime.now().microsecondsSinceEpoch;
    currentUserId = 'user_$uniqueId';
    currentUserName = 'Jogador $uniqueId'; 
  }
  // ---------------------------------------------


  // Stream para buscar todos os quizzes disponíveis
  Stream<QuerySnapshot> _quizzesStream() {
    return _db.collection('quizzes').snapshots();
  }

  // --- Função para Criar e Entrar em uma Sala (Host) ---
  Future<void> _createAndJoinRoom(QuizModel quiz) async {
    // 1. Gera um código de sala simples
    final titlePart = quiz.title.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '').substring(0, 4);
    final randomPart = (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    final roomCode = titlePart + randomPart;

    final roomData = {
      'quizId': quiz.id,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'participants': {
        currentUserId: { // Usando o ID ÚNICO da sessão
          'name': currentUserName,
          'status': 'pronto', 
          'host': true,
        },
      },
    };

    try {
      // 2. Cria o documento da sala no Firestore usando o roomCode como ID
      await _db.collection('rooms').doc(roomCode).set(roomData);
      
      if (mounted) {
        // 3. Navegar para a Sala do Quiz
        // CORREÇÃO APLICADA: Passando o quiz.id
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SalaQuizPage(
            roomId: roomCode, 
            currentUserId: currentUserId, 
            quizId: quiz.id, // <--- CORREÇÃO AQUI: Passando o ID correto do quiz
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao criar sala: $e")),
        );
      }
    }
  }

  // --- Função para Entrar em uma Sala Existente (Jogador) ---
  // FUNÇÃO ATUALIZADA PARA SER ASYNC E BUSCAR O quizId ANTES DE ENTRAR
  Future<void> _joinRoom(BuildContext context, String code) async {
    final roomId = code.toUpperCase().trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O código da sala não pode estar vazio.")),
      );
      return;
    }
    
    // 1. Tenta buscar os dados da sala para obter o quizId
    final roomRef = _db.collection('rooms').doc(roomId);
    DocumentSnapshot roomSnap;
    
    try {
      roomSnap = await roomRef.get();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro de conexão ao buscar sala: $e")),
        );
      }
      return;
    }

    if (!roomSnap.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sala não encontrada. Verifique o código.")),
        );
      }
      return;
    }
    
    // 2. Extrai o quizId
    final roomData = roomSnap.data() as Map<String, dynamic>?;
    final String? quizId = roomData?['quizId'] as String?;

    if (quizId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("A sala está incompleta (quizId ausente).")),
          );
        }
        return;
    }

    // 3. Adiciona o novo participante na sala e navega
    try {
      await roomRef.set({
        'participants': {
          currentUserId: { // Usando o ID ÚNICO da sessão
            'name': currentUserName,
            'status': 'aguardando',
            'host': false,
          }
        }
      }, SetOptions(merge: true));

      if (mounted) {
          // 4. Navega para a Sala do Quiz
          // CORREÇÃO APLICADA: Passando o quizId extraído da sala
          Navigator.of(context).push(MaterialPageRoute(
           builder: (context) => SalaQuizPage(
            roomId: roomId, 
            currentUserId: currentUserId, 
            quizId: quizId, // <--- CORREÇÃO AQUI: Passando o ID do Quiz
           ),
          ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao entrar na sala: ($e)")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exibe o ID e Nome da Sessão Atual para Debug/Teste
            Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text('Sessão: $currentUserName (${currentUserId})', style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 16),
          // Card "Entrar em uma sala"
          _buildJoinRoomCard(),
          const SizedBox(height: 20),

          // Card "Criar novo quiz" (Navega para a nova tela)
          _buildCreateQuizCard(context),
          const SizedBox(height: 28),

          // Quizzes Disponíveis (LISTAGEM DO FIREBASE)
          const Text(
            "Quizzes Disponíveis",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // StreamBuilder para exibir a lista de quizzes em tempo real
          _buildQuizzesList(),
        ],
      ),
    );
  }

  // --- Widgets Auxiliares Refatorados para Limpeza do Código ---

  Widget _buildJoinRoomCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.group_outlined, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                "Entrar em uma Sala",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    hintText: "Digite o código da sala (e.g., QUIZ1234)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3AFF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _joinRoom(context, _codeController.text),
                child: const Text(
                  "Entrar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateQuizCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const CreateQuizPage(),
        ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCED6F5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 32, color: Color(0xFF4A3AFF)),
            const SizedBox(height: 8),
            const Text(
              "Criar Novo Quiz",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2CCF),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Monte suas perguntas e opções!",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A3AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CreateQuizPage(),
                ));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Criar Quiz",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizzesList() {
    return SizedBox(
      height: 250,
      child: StreamBuilder<QuerySnapshot>(
        stream: _quizzesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar quizzes.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Placeholder de exemplo caso o Firestore esteja vazio
            return ListView(
              scrollDirection: Axis.horizontal,
              children: [
                  _buildEmptyQuizCard(title: "Sem Quizzes. Crie um!"),
                  _buildEmptyQuizCard(title: "Seu Quiz pode estar aqui!"),
              ]
            );
          }

          final quizzes = snapshot.data!.docs
              .map((doc) => QuizModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return QuizCard(
                quiz: quiz,
                onTap: () {
                    // Se o host clicar no quiz, ele cria uma sala e entra nela
                    _createAndJoinRoom(quiz);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Card de placeholder para quando não há quizzes no Firestore
  Widget _buildEmptyQuizCard({required String title}) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, color: Colors.grey),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
