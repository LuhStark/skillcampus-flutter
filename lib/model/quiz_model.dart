import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// --- Modelo da Pergunta ---
class QuestionModel {
  final String text;
  final List<String> options; // Lista de 4 opções de resposta
  final int correctAnswerIndex; // Índice da resposta correta (0 a 3)

  QuestionModel({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory QuestionModel.fromFirestore(Map<String, dynamic> data) {
    return QuestionModel(
      text: data['text'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
    );
  }
}

// Mapeia a dificuldade do quiz para a cor do cartão
Color _mapDifficultyToColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'fácil':
      return Colors.green;
    case 'médio':
      return Colors.orange;
    case 'difícil':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// --- Modelo Principal do Quiz ---
class QuizModel {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int questionsCount;
  final Color difficultyColor;
  final int durationMinutes;
  final List<QuestionModel> questions; // Lista de perguntas do quiz

  QuizModel({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.questionsCount,
    required this.durationMinutes,
    required this.questions,
  }) : difficultyColor = _mapDifficultyToColor(difficulty);

  // Construtor a partir do DocumentSnapshot do Firestore
  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Converte a lista de mapas em lista de QuestionModel
    final List<QuestionModel> questionList = (data['questions'] as List<dynamic>?)
        ?.map((q) => QuestionModel.fromFirestore(q as Map<String, dynamic>))
        .toList() ?? [];

    return QuizModel(
      id: doc.id,
      title: data['title'] ?? 'Sem Título',
      category: data['category'] ?? 'Geral',
      difficulty: data['difficulty'] ?? 'Fácil',
      questionsCount: data['questionsCount'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 5,
      questions: questionList,
    );
  }

  // Método para converter o modelo para um mapa (para salvar no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'questionsCount': questions.length, // Atualiza a contagem baseada na lista real
      'durationMinutes': durationMinutes,
      'questions': questions.map((q) => q.toFirestore()).toList(), // Converte perguntas
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
