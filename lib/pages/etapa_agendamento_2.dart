import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'etapa_agendamento_3.dart';

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
            "tempo": item['duracao'], // Corrigido para "duracao"
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

    final int tempoTotalMinutos = servicosSelecionadosComPreco.fold(
  0,
  (soma, item) => soma + ((item['tempo'] ?? 0) as int),
);

final String tempoFormatado = "${tempoTotalMinutos ~/ 60}h${(tempoTotalMinutos % 60).toString().padLeft(2, '0')}";


    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
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
            "Realizar Agendamento",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: servicos.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: servicos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final servico = servicos[index];
                        final selecionado = servicosSelecionados.contains(servico["nome"]);
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
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    servico["imagem"],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        servico["nome"],
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Valor: R\$ ${servico['preco'].toStringAsFixed(2)}",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        "Duração: ${servico['tempo']} min",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    children: [
                      Text(
                        "Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total)}",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "Tempo total: $tempoFormatado minutos",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
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
                                        tempoTotal: tempoTotalMinutos,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
