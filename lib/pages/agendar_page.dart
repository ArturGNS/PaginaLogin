import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'etapa_agendamento_page.dart';

class AgendarPage extends StatefulWidget {
  final String clienteNome;
  final String clienteEmail;
  final String barbeiroNome;
  final String barbeiroEmail;

  const AgendarPage({
    super.key,
    required this.clienteNome,
    required this.clienteEmail,
    required this.barbeiroNome,
    required this.barbeiroEmail,
  });

  @override
  State<AgendarPage> createState() => _AgendarPageState();
}

class _AgendarPageState extends State<AgendarPage> {
  List<String> servicosSelecionados = [];
  List<Map<String, dynamic>> servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/servicos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        servicos = data.map<Map<String, dynamic>>((item) {
          return {
            "nome": item['nome'],
            "imagem": "assets/${item['nome']}_imagem.png",
            "preco": item['preco'].toDouble(),
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicosSelecionadosComPreco = servicos
        .where((s) => servicosSelecionados.contains(s['nome']))
        .toList();

    final double total = servicosSelecionadosComPreco.fold(
        0.0, (soma, item) => soma + (item['preco'] ?? 0.0));

    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C6E49),
        centerTitle: true,
        title: const Text(
          "Realizar Agendamento",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: const Icon(Icons.calendar_today, color: Colors.white),
      ),
      body: servicos.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: servicos.map((servico) {
                        bool selecionado = servicosSelecionados.contains(servico["nome"]);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selecionado) {
                                servicosSelecionados.remove(servico["nome"]);
                              } else {
                                servicosSelecionados.add(servico["nome"]);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selecionado ? Colors.green : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.asset(
                                      servico["imagem"],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    servico["nome"],
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total)}",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: servicosSelecionados.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EtapaAgendamentoPage(
                                        clienteNome: widget.clienteNome,
                                        clienteEmail: widget.clienteEmail,
                                        barbeiroNome: widget.barbeiroNome,
                                        barbeiroEmail: widget.barbeiroEmail,
                                        servicosSelecionados: servicosSelecionados,
                                        statusInicial: 'Pendente',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Agendar", style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              label: const Text("Voltar", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                              },
                              icon: const Icon(Icons.logout, color: Colors.white),
                              label: const Text("Sair", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
