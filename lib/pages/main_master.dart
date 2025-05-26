import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:myapp/pages/editar_usuario_master.dart';
import 'package:myapp/pages/controle_agendamentos_page.dart';
import 'package:myapp/pages/relatorio_master.dart';

class MainPageMaster extends StatelessWidget {
  final String nome;
  final String email;

  const MainPageMaster({Key? key, required this.nome, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2F25),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C6E49),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Painel Master",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Saudação
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bem-vindo, $nome",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.greenAccent,
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/Master_imagem.png'),
                  backgroundColor: Colors.white24,
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Botão Usuários
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsuariosPage()),
                  );
                },
                icon: const Icon(Icons.manage_accounts, color: Colors.white),
                label: const Text("Gerenciar Usuários", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão Agendamentos
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ControleAgendamentosPage()),
                  );
                },
                icon: const Icon(Icons.calendar_month, color: Colors.white),
                label: const Text("Controle de Agendamentos", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão Relatórios
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RelatoriosPage()),
                  );
                },
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                label: const Text("Relatórios e Financeiro", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const Spacer(),

            // Botão sair
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
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
}
