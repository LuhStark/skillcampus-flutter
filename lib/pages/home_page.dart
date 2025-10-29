import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillcampus/pages/inicio_page.dart';
import 'package:skillcampus/pages/login_page.dart';
import 'package:skillcampus/pages/profilepage.dart';
import 'package:skillcampus/pages/rankingpage.dart';

void main() {
  runApp(const SkillCampusApp());
}

class SkillCampusApp extends StatelessWidget {
  const SkillCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillCampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // Variáveis de estado para exibir dados do usuário
  String _userName = "Visitante";
  String _userInitial = "V";
  String _greetingText = "Faça login para começar!";

  // Obtém o usuário atual (pode ser null se não estiver logado)
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Lista de páginas (usando placeholders onde as páginas não foram definidas)
  final List<Widget> _pages = const [
    InicioPage(), 
    // Substituído RankingPage e ProfilePage por placeholders para compilação
    RankingPage(),
    ProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // 1. Tenta obter o nome do usuário logado
    if (currentUser != null) {
      String? displayName = currentUser!.displayName;
      String? email = currentUser!.email;

      String nameToDisplay;
      String initial;

      if (displayName != null && displayName.isNotEmpty) {
        // Opção A: Usa o nome completo (pegando só o primeiro nome para a saudação)
        nameToDisplay = displayName.split(' ')[0]; 
        initial = displayName[0].toUpperCase();
        _greetingText = "Pronto para um novo desafio?";

      } else if (email != null && email.isNotEmpty) {
        // Opção B: Fallback para o email (usa a parte antes do @)
        nameToDisplay = email.split('@')[0];
        initial = email[0].toUpperCase();
        _greetingText = "Complete seu perfil!"; // Nova saudação para incentivar o nome
      } else {
        // Opção C: Fallback geral
        nameToDisplay = "Usuário";
        initial = "U";
      }

      setState(() {
        _userName = nameToDisplay;
        _userInitial = initial;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função para fazer logout
  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            // --------------------- AVATAR DINÂMICO ---------------------
            CircleAvatar(
              backgroundColor: const Color(0xFFD8DCFF),
              // Usa a inicial do nome obtida
              child: Text(_userInitial, style: const TextStyle(color: Colors.black87)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------- NOME DINÂMICO ---------------------
                Text(
                  "Olá, $_userName!", // Usa o nome dinâmico
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // --------------------- SAUDAÇÃO DINÂMICA ---------------------
                Text(
                  _greetingText, // Usa o texto dinâmico
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            // Ícone de Logout
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black54),
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A3AFF),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: "Ranking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
