import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'login_page.dart';
import 'package:myapp/service/usuario_service.dart';

final _mascaraData = MaskTextInputFormatter(
  mask: '##/##/####',
  filter: {"#": RegExp(r'[0-9]')},
);

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text.trim();
      final email = _emailController.text.trim();
      final senha = _senhaController.text;
      final dataNascimento = _dataNascimentoController.text.trim();

      final sucesso = await UsuarioService().cadastrarUsuario(
        nome,
        email,
        senha,
        dataNascimento,
        "cliente",
      );

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar. Tente novamente.')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return "Campo obrigatório";
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.green),
          suffixIcon: onToggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.green,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2C6E49),
        centerTitle: true,
        title: const Text("📝 Cadastro", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  _buildTextField(labelText: "Nome", controller: _nomeController, icon: Icons.person),
                  _buildTextField(labelText: "E-mail", controller: _emailController, icon: Icons.email),
                  _buildTextField(
                    labelText: "Data de Nascimento",
                    controller: _dataNascimentoController,
                    icon: Icons.cake,
                    inputFormatters: [_mascaraData],
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    labelText: "Senha",
                    controller: _senhaController,
                    icon: Icons.lock,
                    obscureText: _senhaOculta,
                    onToggleVisibility: () {
                      setState(() {
                        _senhaOculta = !_senhaOculta;
                      });
                    },
                  ),
                  _buildTextField(
                    labelText: "Confirmar Senha",
                    controller: _confirmarSenhaController,
                    icon: Icons.lock_outline,
                    obscureText: _confirmarSenhaOculta,
                    onToggleVisibility: () {
                      setState(() {
                        _confirmarSenhaOculta = !_confirmarSenhaOculta;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C6E49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Cadastrar", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text("Voltar", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
