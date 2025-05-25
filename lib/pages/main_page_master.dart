import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:myapp/pages/usuarios_page.dart';
import 'package:myapp/pages/controle_agendamentos_page.dart';
import 'package:myapp/pages/relatorio_master_page.dart';

class MainPageMaster extends StatelessWidget {
  final String nome;
  final String email;

  const MainPageMaster({Key? key, required this.nome, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C6E49),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Painel Master", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bem-vindo, $nome',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(email, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),

            // Grid de funcionalidades
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                // Gerenciar Usuários
                _buildItem(
                  context,
                  icon: Icons.manage_accounts,
                  label: "Usuários",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuariosPage())),
                ),

                // Agendamentos
                _buildItem(
                  context,
                  icon: Icons.calendar_month,
                  label: "Agendamentos",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ControleAgendamentosPage())),
                ),

                // Relatórios
                _buildItem(
                  context,
                  icon: Icons.bar_chart,
                  label: "Relatórios",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatoriosPage())),
                ),
              ],
            ),

            const Spacer(),

            // Botão sair
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Sair", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2C6E49), width: 2),
            ),
            child: Icon(icon, color: const Color(0xFF2C6E49), size: 70),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
