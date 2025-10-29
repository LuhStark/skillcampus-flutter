import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  // Instâncias dos serviços Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --------------------------------------------------------------------------
  // FUNÇÃO DE CADASTRO (REGISTER)
  // --------------------------------------------------------------------------
  /// Tenta cadastrar um novo usuário com email e senha e salva o nome no Firestore.
  Future<User?> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Criar o usuário no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Salvar dados adicionais (Nome) no Firestore
        // A collection 'users' armazena o perfil do usuário
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(),
        });
        
        // Opcionalmente, define o nome de exibição do usuário
        await user.updateDisplayName(name);
      }

      return user;
    } on FirebaseAuthException {
      // Repassa a exceção para ser tratada pela UI (RegisterPage)
      rethrow; 
    } catch (e) {
      // Lidar com outros erros (ex: erro de conexão, erro no Firestore)
      print('Erro inesperado durante o cadastro: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // FUNÇÃO DE LOGIN (SIGN IN)
  // --------------------------------------------------------------------------
  /// Tenta autenticar um usuário com email e senha.
  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print('Erro inesperado durante o login: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // FUNÇÃO DE LOGOUT (SIGN OUT)
  // --------------------------------------------------------------------------
  /// Desconecta o usuário atualmente logado.
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // --------------------------------------------------------------------------
  // STREAM DO ESTADO DE AUTENTICAÇÃO
  // --------------------------------------------------------------------------
  /// Retorna um stream que notifica sobre mudanças no estado de autenticação (login/logout).
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
