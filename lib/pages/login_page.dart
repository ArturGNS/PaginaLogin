import 'package:flutter/material.dart';
import 'package:myapp/pages/main_page_funcionario.dart';
import 'package:myapp/pages/main_page_master.dart';
import 'package:myapp/pages/register_page.dart';
import 'package:myapp/service/usuario_service.dart';
import 'package:myapp/pages/esqueci_senha_page.dart';
import 'package:myapp/pages/main_cliente_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _login() async {
    String email = _emailController.text.trim();
    String senha = _passwordController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final usuario = await UsuarioService().verificarLogin(email, senha);

    if (usuario != null) {
      String tipo = usuario['tipo'];

      if (tipo == 'master') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPageMaster(
              nome: usuario['nome'],
              email: usuario['email'],
            ),
          ),
        );
      } else if (tipo == 'cliente') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainClientePage(
              clienteNome: usuario['nome'],
              clienteEmail: usuario['email'],
            ),
          ),
        );
      } else if (tipo == 'funcionario') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPageFuncionario(
              nome: usuario['nome'],
              email: usuario['email'],
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email ou senha incorretos!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    bool obscureText = false,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white60),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.green),
          suffixIcon: obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF101820),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final largura = constraints.maxWidth;
                    final tamanho = largura * 0.5;

                    return Image.asset(
                      'assets/Barbersync_logo_novo.png',
                      width: tamanho,
                      height: tamanho,
                    );
                  },
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  labelText: "Informe seu Email",
                  controller: _emailController,
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  labelText: "Informe sua Senha",
                  controller: _passwordController,
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EsqueciSenhaPage()),
                      );
                    },
                    child: const Text(
                      "Esqueceu a senha?",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6E49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Ainda não tem uma conta? ",
                      style: TextStyle(color: Colors.white60),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Cadastre-se",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
