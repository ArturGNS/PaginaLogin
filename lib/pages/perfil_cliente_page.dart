import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/pages/trocar_senha.dart';

class PerfilClientePage extends StatefulWidget {
  final String nome;
  final String email;

  const PerfilClientePage({super.key, required this.nome, required this.email});

  @override
  State<PerfilClientePage> createState() => _PerfilClientePageState();
}

class _PerfilClientePageState extends State<PerfilClientePage> {
  String dataNascimento = '';
  int totalServicos = 0;
  double totalGasto = 0.0;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final usuariosRes = await http.get(Uri.parse('http://localhost:3000/usuarios'));
    final agendamentosRes = await http.get(Uri.parse('http://localhost:3000/agendamentos'));

    if (usuariosRes.statusCode == 200) {
      final usuarios = json.decode(usuariosRes.body);
      final usuario = usuarios.firstWhere((u) => u['email'] == widget.email, orElse: () => null);
      if (usuario != null && mounted) {
        setState(() => dataNascimento = usuario['dataNascimento'] ?? '');
      }
    }

    if (agendamentosRes.statusCode == 200) {
      final hoje = DateTime.now();
      final ags = json.decode(agendamentosRes.body)
          .where((a) {
            final emailOk = a['clienteEmail'] == widget.email;
            final data = DateTime.tryParse(a['data'] ?? '');
            final dataOk = data != null && data.isBefore(hoje.add(const Duration(days: 1)));
            return emailOk && dataOk;
          })
          .toList();

      setState(() {
        totalServicos = ags.length;
        totalGasto = ags.fold(0.0, (sum, a) => sum + (a['valorTotal'] ?? 0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111319),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFF1C2F25),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C6E49),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(widget.nome, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.email, style: const TextStyle(color: Colors.white70)),
            if (dataNascimento.isNotEmpty)
              Text("Nascimento: $dataNascimento", style: const TextStyle(color: Colors.white54)),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C6E49),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoBox('Total Gasto', NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(totalGasto)),
                  _infoBox('Serviços', '$totalServicos'),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: Colors.greenAccent),
                    title: const Text("Trocar Senha", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrocarSenhaPage(email: widget.email),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(Icons.photo_camera_back_outlined, color: Colors.greenAccent),
                    title: const Text("Alterar Foto de Perfil", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Lógica futura de upload
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

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
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
