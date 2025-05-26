import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  List<dynamic> agendamentos = [];
  List<dynamic> barbeiros = [];
  String? barbeiroSelecionado;
  DateTime? dataInicio;
  DateTime? dataFim;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final responseAg = await http.get(Uri.parse('http://localhost:3000/agendamentos'));
    final responseFunc = await http.get(Uri.parse('http://localhost:3000/usuarios'));

    if (responseAg.statusCode == 200 && responseFunc.statusCode == 200) {
      final List<dynamic> todosAgendamentos = json.decode(responseAg.body);
      final List<dynamic> todosUsuarios =
          json.decode(responseFunc.body).where((u) => u['tipo'] == 'funcionario').toList();

      setState(() {
        agendamentos = todosAgendamentos;
        barbeiros = todosUsuarios;
        barbeiroSelecionado = 'Todos';
        dataInicio = null;
        dataFim = null;
      });
    }
  }

  List<dynamic> get agendamentosFiltrados {
    List<dynamic> filtrados = agendamentos.where((ag) {
      final dataHoraStr = '${ag['data'].toString().split("T")[0]} ${ag['horario']}';
      final DateTime dataHora = DateFormat('yyyy-MM-dd HH:mm').parse(dataHoraStr);

      final barbeiroOk = barbeiroSelecionado == 'Todos' || ag['barbeiro'] == barbeiroSelecionado;
      final dataOk = (dataInicio == null || dataHora.isAfter(dataInicio!.subtract(const Duration(days: 1)))) &&
          (dataFim == null || dataHora.isBefore(dataFim!.add(const Duration(days: 1))));

      return barbeiroOk && dataOk;
    }).toList();

    filtrados.sort((a, b) {
      final da = DateFormat('yyyy-MM-dd HH:mm')
          .parse('${a['data'].toString().split("T")[0]} ${a['horario']}');
      final db = DateFormat('yyyy-MM-dd HH:mm')
          .parse('${b['data'].toString().split("T")[0]} ${b['horario']}');
      return da.compareTo(db);
    });

    return filtrados;
  }

  double get totalFaturado => agendamentosFiltrados.fold(0.0, (soma, ag) => soma + (ag['valorTotal'] ?? 0.0));

  Future<void> selecionarPeriodo() async {
    final intervalo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2100),
      initialDateRange: dataInicio != null && dataFim != null ? DateTimeRange(start: dataInicio!, end: dataFim!) : null,
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (intervalo != null) {
      setState(() {
        dataInicio = intervalo.start;
        dataFim = intervalo.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111319),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2F25),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C6E49),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Relatórios e Financeiro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1A1D25),
                    value: barbeiroSelecionado,
                    onChanged: (String? value) => setState(() => barbeiroSelecionado = value!),
                    items: [
                      const DropdownMenuItem(
                        value: 'Todos',
                        child: Text('Todos', style: TextStyle(color: Colors.white)),
                      ),
                      ...barbeiros.map((b) => DropdownMenuItem<String>(
                            value: b['nome'],
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: AssetImage("assets/${b['nome']}_imagem.png"),
                                  backgroundColor: Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Text(b['nome'], style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          )),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Funcionário',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF1A1D25),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: selecionarPeriodo,
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: const Text("Período", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C6E49),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: Text(
                dataInicio != null && dataFim != null
                    ? 'Período: ${DateFormat('dd/MM/yyyy').format(dataInicio!)} até ${DateFormat('dd/MM/yyyy').format(dataFim!)}'
                    : 'Período: Todos os agendamentos',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Faturado: R\$ ${totalFaturado.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF47D178),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: agendamentosFiltrados.length,
                itemBuilder: (context, index) {
                  final ag = agendamentosFiltrados[index];
                  final barbeiro = barbeiros.firstWhere((b) => b['nome'] == ag['barbeiro'], orElse: () => null);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: barbeiro != null
                              ? AssetImage('assets/${barbeiro['nome']}_imagem.png')
                              : null,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ag['barbeiro'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${ag['cliente']} • ${ag['servicos'].join(', ')}',
                                  style: const TextStyle(color: Colors.white70)),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(DateTime.parse(ag['data']))} às ${ag['horario']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text('R\$ ${ag['valorTotal'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Color(0xFF47D178), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
}
