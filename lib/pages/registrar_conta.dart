import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:myapp/service/usuario_service.dart';
import 'login_page.dart';

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
  final _dataController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      final sucesso = await UsuarioService().cadastrarUsuario(
        _nomeController.text.trim(),
        _emailController.text.trim(),
        _senhaController.text,
        _dataController.text.trim(),
        'cliente',
      );

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar. Tente novamente.')),
        );
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    VoidCallback? toggle,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        inputFormatters: formatters,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
          if (controller == _confirmarSenhaController && value != _senhaController.text) {
            return 'Senhas não coincidem';
          }
          if (controller == _senhaController && value.length < 6) {
            return 'Senha deve ter pelo menos 6 caracteres';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.green),
          suffixIcon: toggle != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.green),
                  onPressed: toggle,
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Icon(Icons.person_add_alt_1, size: 50, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        "Crie sua conta preenchendo os dados abaixo",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _nomeController,
                        icon: Icons.person,
                        hint: "Nome completo",
                      ),
                      _buildInputField(
                        controller: _emailController,
                        icon: Icons.email,
                        hint: "E-mail",
                      ),
                      _buildInputField(
                        controller: _dataController,
                        icon: Icons.cake,
                        hint: "Data de Nascimento (dd/mm/yyyy)",
                        formatters: [_mascaraData],
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: _senhaController,
                        icon: Icons.lock,
                        hint: "Senha",
                        obscure: _senhaOculta,
                        toggle: () => setState(() => _senhaOculta = !_senhaOculta),
                      ),
                      _buildInputField(
                        controller: _confirmarSenhaController,
                        icon: Icons.lock_outline,
                        hint: "Confirmar Senha",
                        obscure: _confirmarSenhaOculta,
                        toggle: () => setState(() => _confirmarSenhaOculta = !_confirmarSenhaOculta),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: _registrar,
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text("Cadastrar", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C6E49),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text("Voltar", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
