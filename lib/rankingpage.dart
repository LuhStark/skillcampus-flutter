import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int _selectedTab = 1; // aba inferior atual (Ranking)
  String _selectedFilter = "Semanal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rankings Globais',
          style: TextStyle(
            color: Color(0xFF4A3AFF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posição atual e melhor posição
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sua posição atual',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('8º',
                          style: TextStyle(
                              color: Color(0xFF4A3AFF),
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Melhor posição',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('3º',
                          style: TextStyle(
                              color: Color(0xFF4A3AFF),
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filtro Semanal / Mensal
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterButton("Semanal"),
                const SizedBox(width: 10),
                _filterButton("Mensal"),
              ],
            ),
            const SizedBox(height: 20),

            // Lista de ranking
            _rankingItem(1, "Marina Lopes", 2500, "+2"),
            _rankingItem(2, "Carlos Nunes", 2400, "+1"),
            _rankingItem(3, "Ana Paula", 2320, "-1"),
            _rankingItem(4, "Lucas Vieira", 2280, "+3"),
            _rankingItem(5, "Você", 2200, "+2", isUser: true),

            const SizedBox(height: 30),

            const Text(
              "Melhores por Categoria",
              style: TextStyle(
                color: Color(0xFF4A3AFF),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),

            _categoryCard("Matemática", "Juliana Campos", 920),
            _categoryCard("Ciências", "Pedro Lima", 870),
            _categoryCard("História", "Maria Souza", 840),
            const SizedBox(height: 25),

            // Card roxo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3AFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suba no Ranking!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Continue estudando e acumule mais XP para alcançar o topo!",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      )
    );
  }

  // --- Widgets auxiliares ---
  Widget _filterButton(String label) {
    final bool isSelected = _selectedFilter == label;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF4A3AFF) : Colors.white,
        foregroundColor:
            isSelected ? Colors.white : const Color(0xFF4A3AFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFF4A3AFF)),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _rankingItem(int pos, String nome, int pontos, String variacao,
      {bool isUser = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFEAE8FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$posº",
              style: const TextStyle(
                  color: Color(0xFF4A3AFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(nome,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)))),
          Text("$pontos XP",
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w400)),
          const SizedBox(width: 10),
          Text(variacao,
              style: TextStyle(
                  color: variacao.startsWith("+")
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _categoryCard(String categoria, String nome, int pontos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(categoria,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3AFF),
                  fontSize: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(nome,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15)),
              Text("$pontos XP",
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
