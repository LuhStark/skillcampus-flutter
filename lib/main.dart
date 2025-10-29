import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skillcampus/firebase_options.dart';
import 'package:skillcampus/pages/home_page.dart';
import 'package:skillcampus/pages/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se ainda está carregando, mostra um indicador
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          // Se houver um usuário logado (snapshot.hasData é true), vai para Home
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Caso contrário (deslogado), vai para a LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}