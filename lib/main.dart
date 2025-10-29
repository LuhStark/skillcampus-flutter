import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skillcampus/pages/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase inicializado com sucesso.");
  } catch (e) {
    print("Erro ao inicializar o Firebase: $e");
    // Você pode querer exibir um erro para o usuário aqui.
  }
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