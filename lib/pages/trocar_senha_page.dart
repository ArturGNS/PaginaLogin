import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrocarSenhaPage extends StatefulWidget {
  final String email;

  const TrocarSenhaPage({Key? key, required this.email}) : super(key: key);

  @override
  State<TrocarSenhaPage> createState() => _TrocarSenhaPageState();
}

class _TrocarSenhaPageState extends State<TrocarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  String? senhaAtualSalva;

  @override
  void initState() {
    super.initState();
    carregarSenhaAtual();
  }

  Future<void> carregarSenhaAtual() async {
    final response = await http.get(Uri.parse('http://localhost:3000/usuarios'));
    if (response.statusCode == 200) {
      final usuarios = json.decode(response.body);
      final usuario = usuarios.firstWhere((u) => u['email'] == widget.email, orElse: () => null);
      if (usuario != null) {
        senhaAtualSalva = usuario['senha'];
      }
    }
  }

  Future<void> trocarSenha() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.get(Uri.parse('http://localhost:3000/usuarios'));
    final usuarios = json.decode(response.body);
    final usuario = usuarios.firstWhere((u) => u['email'] == widget.email);

    final atualizado = Map<String, dynamic>.from(usuario);
    atualizado['senha'] = _novaSenhaController.text;

    final put = await http.put(
      Uri.parse('http://localhost:3000/usuarios/${usuario['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(atualizado),
    );

    if (put.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar a senha.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1C2F25),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C6E49),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Trocar Senha',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D25),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_reset_rounded, size: 48, color: Colors.greenAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Atualize sua senha com segurança',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _senhaAtualController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Senha Atual',
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.greenAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                borderSide: BorderSide(color: Colors.greenAccent),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Informe sua senha atual';
                              if (value != senhaAtualSalva) return 'Senha atual incorreta';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _novaSenhaController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Nova Senha',
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
                              prefixIcon: Icon(Icons.lock, color: Colors.greenAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                borderSide: BorderSide(color: Colors.greenAccent),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Digite a nova senha';
                              if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmarSenhaController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Confirmar Nova Senha',
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
                              prefixIcon: Icon(Icons.lock, color: Colors.greenAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                borderSide: BorderSide(color: Colors.greenAccent),
                              ),
                            ),
                            validator: (value) {
                              if (value != _novaSenhaController.text) return 'As senhas não coincidem';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: trocarSenha,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text("Atualizar Senha", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C6E49),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text("Voltar", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Sair", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
