import 'package:flutter/material.dart';
import 'package:skillcampus/pages/home_page.dart';
import 'package:skillcampus/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Função fictícia de cadastro
  void _handleRegister() {
    // Aqui você implementaria a lógica real de cadastro (ex: Firebase, API)
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      // Em uma aplicação real, você mostraria uma mensagem de erro na UI,
      // pois `alert()` não é recomendado no Flutter (ou em iframes/web).
      print('Erro: Senhas não conferem.');
      return;
    }

    print(
        'Tentativa de Cadastro: Nome: $name, Email: $email, Senha: $password');

    // Simula o sucesso do cadastro e navega para a Home
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const HomePage()), // Assumindo HomePage existe
    );
  }

  // Função para navegar de volta ao login
  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // O SingleChildScrollView garante que o teclado não cubra os campos em dispositivos menores.
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
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
                  'Crie sua conta para começar seus quizzes',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                const SizedBox(height: 32),

                // --------------------- CAMPO NOME ---------------------
                _buildTextField(
                  label: 'Nome',
                  hint: 'Digite seu nome completo',
                  controller: _nameController,
                  obscure: false,
                ),
                const SizedBox(height: 16),

                // --------------------- CAMPO EMAIL ---------------------
                _buildTextField(
                  label: 'Email',
                  hint: 'Digite seu email',
                  controller: _emailController,
                  obscure: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // --------------------- CAMPO SENHA ---------------------
                _buildTextField(
                  label: 'Senha',
                  hint: 'Crie uma senha',
                  controller: _passwordController,
                  obscure: true,
                ),
                const SizedBox(height: 16),

                // --------------------- CAMPO CONFIRMAR SENHA ---------------------
                _buildTextField(
                  label: 'Confirmar Senha',
                  hint: 'Digite a senha novamente',
                  controller: _confirmPasswordController,
                  obscure: true,
                ),
                const SizedBox(height: 24),

                // --------------------- BOTÃO CADASTRAR ---------------------
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
                    onPressed: _handleRegister,
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --------------------- LINK JÁ TEM CONTA ---------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem uma conta?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _goToLogin,
                      child: const Text(
                        'Fazer Login',
                        style: TextStyle(
                          color: Color(0xFF4A3AFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para construir os campos de texto com o estilo padrão
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: const TextStyle(color: Colors.black87)),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF4A3AFF), width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
          ),
        ),
      ],
    );
  }
}
