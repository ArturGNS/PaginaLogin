import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RelatorioClientePage extends StatefulWidget {
  final String clienteNome;
  final String clienteEmail;

  const RelatorioClientePage({
    super.key,
    required this.clienteNome,
    required this.clienteEmail,
  });

  @override
  State<RelatorioClientePage> createState() => _RelatorioClientePageState();
}

class _RelatorioClientePageState extends State<RelatorioClientePage> {
  List<dynamic> agendamentos = [];
  DateTime? dataInicio;
  DateTime? dataFim;
  String statusSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  Future<void> carregarAgendamentos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/agendamentos'));

    if (response.statusCode == 200) {
      final List<dynamic> todos = json.decode(response.body);
      final List<dynamic> doCliente =
          todos.where((a) => a['clienteEmail'] == widget.clienteEmail).toList();
      setState(() => agendamentos = doCliente);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar agendamentos')),
      );
    }
  }

  List<dynamic> get agendamentosFiltrados {
    return agendamentos.where((a) {
      final data = DateTime.tryParse(a['data'] ?? '');
      final statusOk = statusSelecionado == 'Todos' || a['status'] == statusSelecionado;
      final dataOk = (dataInicio == null || data!.isAfter(dataInicio!.subtract(const Duration(days: 1)))) &&
          (dataFim == null || data!.isBefore(dataFim!.add(const Duration(days: 1))));
      return statusOk && dataOk;
    }).toList();
  }

  double get totalFaturado => agendamentosFiltrados.fold<double>(
        0.0,
        (soma, ag) => soma + ((ag['valorTotal'] ?? 0) as num).toDouble(),
      );

  Future<void> selecionarPeriodo() async {
    final intervalo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDateRange: dataInicio != null && dataFim != null
          ? DateTimeRange(start: dataInicio!, end: dataFim!)
          : null,
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );

    if (intervalo != null) {
      setState(() {
        dataInicio = intervalo.start;
        dataFim = intervalo.end;
      });
    }
  }

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'concluido':
        return Colors.greenAccent;
      case 'cancelado':
        return Colors.redAccent;
      case 'pendente':
        return Colors.amberAccent;
      default:
        return Colors.white70;
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
            'Relatório de Agendamentos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: statusSelecionado,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF1A1D25),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    dropdownColor: const Color(0xFF1A1D25),
                    style: const TextStyle(color: Colors.white),
                    items: ['Todos', 'Pendente', 'Concluido', 'Cancelado']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => statusSelecionado = value ?? 'Todos');
                    },
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
              'Total Gasto: R\$ ${totalFaturado.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF47D178),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            // Lista
            Expanded(
              child: ListView.builder(
                itemCount: agendamentosFiltrados.length,
                itemBuilder: (context, index) {
                  final ag = agendamentosFiltrados[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(ag['data'])), style: const TextStyle(color: Colors.white70)),
                        Text('Horário: ${ag['horario']}', style: const TextStyle(color: Colors.white70)),
                        Text('Serviços: ${ag['servicos'].join(', ')}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('Status: ${ag['status']}', style: TextStyle(color: _corStatus(ag['status']))),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${ag['valorTotal'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF47D178),
                            fontWeight: FontWeight.bold,
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
