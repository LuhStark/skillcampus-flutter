import 'package:flutter/material.dart';
import "homepage.dart";


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
        fontFamily: 'Arial',
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SkillCampus',
                style: TextStyle(
                  color: Color(0xFF3B2CCF),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entre para começar seus quizzes',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 32),

              // Campo Email
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: TextStyle(color: Colors.black87)),
              ),
              const SizedBox(height: 4),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Digite seu email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F6FA),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Senha
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Senha', style: TextStyle(color: Colors.black87)),
              ),
              const SizedBox(height: 4),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Digite sua senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F6FA),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text(
                    'Entrar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botão Cadastrar
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Link Recuperar senha
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Esqueceu sua senha?'),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Recuperar senha',
                      style: TextStyle(
                        color: Color(0xFF4A3AFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contas de demonstração
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCED6F5)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Contas de demonstração:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B2CCF),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('maria@exemplo.com | senha: 123456'),
                    Text('joao@exemplo.com | senha: 123456'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
