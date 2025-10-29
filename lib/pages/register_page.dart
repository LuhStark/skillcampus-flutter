import 'package:flutter/material.dart';
import 'package:skillcampus/pages/home_page.dart';
import 'package:skillcampus/pages/login_page.dart';
import 'package:skillcampus/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Chave global para o formulário para validação
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService(); // Instância do serviço
  bool _isLoading = false;
  String? _errorMessage;

  // Função principal de cadastro integrada com Firebase
  Future<void> _handleRegister() async {
    // 1. Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return; // Se a validação falhar, para aqui.
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // 2. Chamar o serviço de registro do Firebase
      await _authService.registerWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );

      // 3. Sucesso: Navegar para a Home e remover a tela de registro da pilha
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false, // Remove todas as rotas anteriores
        );
      }
    } on FirebaseAuthException catch (e) {
      // 4. Tratar erros do Firebase
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Já existe uma conta com este email.';
      } else {
        message = 'Erro ao cadastrar. Tente novamente: ${e.code}';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      // 5. Tratar outros erros (como erro de conexão)
      setState(() {
        _errorMessage = 'Ocorreu um erro inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para navegar para a tela de login
  void _goToLogin() {
    // Usa pop para voltar se o login estiver na pilha, ou push se for a primeira tela
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O SingleChildScrollView garante que o teclado não cubra os campos em dispositivos menores.
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
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
            // O Form Widget permite a validação
            child: Form(
              key: _formKey,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O nome é obrigatório.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --------------------- CAMPO EMAIL ---------------------
                  _buildTextField(
                    label: 'Email',
                    hint: 'Digite seu email',
                    controller: _emailController,
                    obscure: false,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Informe um email válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --------------------- CAMPO SENHA ---------------------
                  _buildTextField(
                    label: 'Senha',
                    hint: 'Crie uma senha',
                    controller: _passwordController,
                    obscure: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --------------------- CAMPO CONFIRMAR SENHA ---------------------
                  _buildTextField(
                    label: 'Confirmar Senha',
                    hint: 'Digite a senha novamente',
                    controller: _confirmPasswordController,
                    obscure: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'As senhas não conferem.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // --------------------- MENSAGEM DE ERRO ---------------------
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),

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
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : const Text(
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
      ),
    );
  }

  // Widget auxiliar para construir os campos de texto com o estilo padrão
  // CORRIGIDO para usar TextFormField e aceitar o validator.
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    String? Function(String?)? validator, // Adicionado para validação
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
        // Alterado de TextField para TextFormField
        TextFormField( 
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator, // Propriedade de validação
          decoration: InputDecoration( // Removido o 'const' daqui
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
            // Estilos de borda de erro adicionados para que a validação do TextFormField funcione corretamente
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
          ),
        ),
      ],
    );
  }
}
