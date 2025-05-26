import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:myapp/pages/agenda_barbeiro.dart';
import 'package:myapp/pages/relatorio_funcionario.dart';

class MainPageFuncionario extends StatelessWidget {
  final String nome;
  final String email;

  const MainPageFuncionario({
    Key? key,
    required this.nome,
    required this.email,
  }) : super(key: key);

  String get imagemBarbeiro {
    final nomeBase = nome.split(' ').first;
    return 'assets/${nomeBase}_imagem.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820), // fundo escuro elegante
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1C2F25), // fundo mais escuro
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C6E49),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Área do Barbeiro",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey, $nome",
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagemBarbeiro,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.white24,
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // BOTÃO AGENDA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgendaBarbeiroPage(
                        usuarioLogado: {'nome': nome, 'email': email},
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.schedule, color: Colors.white),
                label: const Text("Visualizar Agenda", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BOTÃO RELATÓRIO
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatorioFuncionarioPage(
                        nome: nome,
                        email: email,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                label: const Text("Visualizar Relatório", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49), // mesma cor do botão anterior
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const Spacer(),

            // BOTÃO SAIR
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white, size: 16),
                label: const Text("Sair", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
