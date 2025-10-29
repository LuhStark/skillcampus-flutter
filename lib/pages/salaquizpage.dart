import 'package:flutter/material.dart';

class SalaQuizPage extends StatefulWidget {
  const SalaQuizPage({super.key});

  @override
  State<SalaQuizPage> createState() => _SalaQuizPageState();
}

class _SalaQuizPageState extends State<SalaQuizPage> {
  // Dados simulados da sala
  final String codigoSala = "QUIZ123";
  final String temaQuiz = "Geografia";
  final int perguntas = 10;
  final int tempoPorPergunta = 30;
  final String dificuldade = "Médio";

  // Lista de participantes (mock)
  List<Map<String, dynamic>> participantes = [
    {"nome": "João Silva", "status": "pronto", "host": true},
    {"nome": "Maria Santos", "status": "pronto", "host": false},
    {"nome": "Pedro Lima", "status": "aguardando", "host": false},
    {"nome": "Ana Costa", "status": "pronto", "host": false},
  ];

  @override
  Widget build(BuildContext context) {
    int prontos = participantes.where((p) => p['status'] == 'pronto').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala do Quiz'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF1F4FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // CÓDIGO DA SALA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  const Text(
                    'Código da Sala',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    codigoSala,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFF4A3AFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Compartilhe este código com seus amigos'),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                    ),
                    onPressed: () {
                      // apenas simula o copiar código
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Código copiado!")),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Código'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // INFO DO QUIZ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quiz de $temaQuiz', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Perguntas: $perguntas'),
                  Text('Tempo por pergunta: $tempoPorPergunta segundos'),
                  Text('Dificuldade: $dificuldade'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PARTICIPANTES
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Participantes (${participantes.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...participantes.map((p) {
                    final cor = p['status'] == 'pronto'
                        ? Colors.green
                        : p['status'] == 'aguardando'
                            ? Colors.orange
                            : Colors.grey;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEDE7F6),
                        child: Text(
                          p['nome'][0],
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(p['nome']),
                          if (p['host'] == true)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE7F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Host',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: cor, size: 12),
                          const SizedBox(width: 4),
                          Text(p['status'].toString().capitalize()),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BARRA DE STATUS
            Text('$prontos de ${participantes.length} participantes prontos'),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: participantes.isEmpty ? 0 : prontos / participantes.length,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xFF4A3AFF),
              minHeight: 8,
            ),

            const SizedBox(height: 20),

            // BOTÃO PRONTO / INICIAR QUIZ
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() {
                    // Simula o jogador ficando pronto
                    participantes[2]['status'] = 'pronto'; // Exemplo: Pedro Lima muda para pronto
                  });
                },
                child: const Text(
                  'Iniciar Quiz',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
