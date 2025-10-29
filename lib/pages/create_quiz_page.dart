import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skillcampus/model/quiz_model.dart';

// Classe que armazena o estado temporário de uma pergunta no formulário
class QuestionFormState {
  final TextEditingController questionTextController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
  int correctAnswerIndex = 0; // 0 a 3

  void dispose() {
    questionTextController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
  }

  // Converte o estado do formulário para o modelo de dados do Firestore
  QuestionModel toModel() {
    return QuestionModel(
      text: questionTextController.text,
      options: optionControllers.map((c) => c.text).toList(),
      correctAnswerIndex: correctAnswerIndex,
    );
  }
}

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controladores para as informações gerais do Quiz
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _difficulty = 'Fácil';

  // Lista de estados de formulário para as perguntas (min 5, max 20)
  List<QuestionFormState> _questions = List.generate(5, (_) => QuestionFormState());

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  // Função para adicionar uma nova pergunta
  void _addQuestion() {
    if (_questions.length < 20) {
      setState(() {
        _questions.add(QuestionFormState());
      });
    }
  }

  // Função para remover uma pergunta
  void _removeQuestion(int index) {
    if (_questions.length > 5) {
      setState(() {
        _questions[index].dispose();
        _questions.removeAt(index);
      });
    }
  }

  // Função principal para salvar o Quiz no Firestore
  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Validar se todas as perguntas têm 4 opções preenchidas e a pergunta em si
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionTextController.text.trim().isEmpty) {
        _showSnackbar('Preencha o texto da Pergunta ${i + 1}.');
        return;
      }
      for (var j = 0; j < 4; j++) {
        if (q.optionControllers[j].text.trim().isEmpty) {
          _showSnackbar('Preencha todas as 4 opções na Pergunta ${i + 1}.');
          return;
        }
      }
    }

    // 2. Criar a lista de QuestionModel
    final List<QuestionModel> questionModels = _questions.map((q) => q.toModel()).toList();

    // 3. Criar o QuizModel final
    final QuizModel newQuiz = QuizModel(
      id: '', // ID será gerado pelo Firestore
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      difficulty: _difficulty,
      questionsCount: questionModels.length,
      durationMinutes: questionModels.length * 0.5 ~/ 1 + 5, // Duração calculada (5s por pergunta + 5 min base)
      questions: questionModels,
    );

    // 4. Salvar no Firestore
    try {
      await _db.collection('quizzes').add(newQuiz.toFirestore());
      _showSnackbar('Quiz "${newQuiz.title}" criado com sucesso!', isError: false);
      if (mounted) {
        Navigator.pop(context); // Volta para a tela inicial
      }
    } catch (e) {
      _showSnackbar('Erro ao salvar o quiz: $e');
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Novo Quiz'),
        backgroundColor: const Color(0xFF4A3AFF),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEÇÃO DE INFORMAÇÕES GERAIS ---
              const Text('Informações Gerais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3AFF))),
              const Divider(),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título do Quiz'),
                validator: (value) => value!.isEmpty ? 'O título é obrigatório.' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoria (Ex: História, Esportes)'),
                validator: (value) => value!.isEmpty ? 'A categoria é obrigatória.' : null,
              ),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Dificuldade'),
                items: ['Fácil', 'Médio', 'Difícil']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 30),

              // --- SEÇÃO DE PERGUNTAS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Perguntas (${_questions.length}/20)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3AFF))),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Adicionar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Mínimo de 5 perguntas, máximo de 20.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 10),

              ..._questions.asMap().entries.map((entry) {
                int index = entry.key;
                QuestionFormState qState = entry.value;

                return _buildQuestionCard(index, qState);
              }).toList(),

              const SizedBox(height: 30),

              // --- BOTÃO SALVAR ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveQuiz,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Salvar Quiz', style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3AFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Constrói o cartão de edição para cada pergunta
  Widget _buildQuestionCard(int index, QuestionFormState qState) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pergunta ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (_questions.length > 5)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _removeQuestion(index),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Campo de texto da Pergunta
          TextFormField(
            controller: qState.questionTextController,
            decoration: const InputDecoration(
              hintText: 'Digite o texto da pergunta',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
          const SizedBox(height: 15),
          const Text('Opções de Resposta (Marque a correta):', style: TextStyle(fontWeight: FontWeight.w500)),
          
          // Campos das 4 Opções
          ...List.generate(4, (optionIndex) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Radio<int>(
                    value: optionIndex,
                    groupValue: qState.correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        qState.correctAnswerIndex = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: qState.optionControllers[optionIndex],
                      decoration: InputDecoration(
                        hintText: 'Opção ${optionIndex + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        // Destaca visualmente a resposta correta
                        suffixIcon: qState.correctAnswerIndex == optionIndex
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
