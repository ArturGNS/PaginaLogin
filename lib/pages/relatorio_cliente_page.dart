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
  List<dynamic> barbeiros = [];
  DateTime? dataInicio;
  DateTime? dataFim;
  String statusSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final responseAg = await http.get(Uri.parse('http://localhost:3000/agendamentos'));
    final responseBarb = await http.get(Uri.parse('http://localhost:3000/usuarios'));

    if (responseAg.statusCode == 200 && responseBarb.statusCode == 200) {
      final List<dynamic> todos = json.decode(responseAg.body);
      final List<dynamic> barbeirosData = json.decode(responseBarb.body);
      final List<dynamic> doCliente =
          todos.where((a) => a['clienteEmail'] == widget.clienteEmail).toList();
      setState(() {
        agendamentos = doCliente;
        barbeiros = barbeirosData.where((b) => b['tipo'] == 'funcionario').toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados')),
      );
    }
  }

  List<dynamic> get agendamentosFiltrados {
    final filtrados = agendamentos.where((a) {
      final data = DateTime.tryParse(a['data'] ?? '');
      final statusOk = statusSelecionado == 'Todos' || a['status'] == statusSelecionado;
      final dataOk = (dataInicio == null || data!.isAfter(dataInicio!.subtract(const Duration(days: 1)))) &&
          (dataFim == null || data!.isBefore(dataFim!.add(const Duration(days: 1))));
      return statusOk && dataOk;
    }).toList();

    filtrados.sort((a, b) {
      final dataA = DateTime.parse(a['data']);
      final dataB = DateTime.parse(b['data']);
      final horaA = TimeOfDay(
        hour: int.parse(a['horario'].split(':')[0]),
        minute: int.parse(a['horario'].split(':')[1]),
      );
      final horaB = TimeOfDay(
        hour: int.parse(b['horario'].split(':')[0]),
        minute: int.parse(b['horario'].split(':')[1]),
      );
      final dateTimeA = DateTime(dataA.year, dataA.month, dataA.day, horaA.hour, horaA.minute);
      final dateTimeB = DateTime(dataB.year, dataB.month, dataB.day, horaB.hour, horaB.minute);
      return dateTimeA.compareTo(dateTimeB);
    });

    return filtrados;
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

  Map<String, dynamic>? _getBarbeiro(String email) {
    return barbeiros.firstWhere(
      (b) => b['email'] == email,
      orElse: () => {'nome': 'Desconhecido', 'email': '', 'imagem': 'assets/default.png'},
    );
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
            Text(
              dataInicio != null && dataFim != null
                  ? 'Período: ${DateFormat('dd/MM/yyyy').format(dataInicio!)} até ${DateFormat('dd/MM/yyyy').format(dataFim!)}'
                  : 'Período: Todos os agendamentos',
              style: const TextStyle(color: Colors.white70),
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
                  final barbeiro = _getBarbeiro(ag['barbeiroEmail']);
                  final imagemNome = barbeiro?['nome'] ?? 'Barbeiro'.toString().split(' ').first;
                  final imagem = 'assets/${imagemNome}_imagem.png';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topo com imagem e nome do barbeiro
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                imagem,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.white24,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                barbeiro?['nome'] ?? 'Barbeiro',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              ag['status'],
                              style: TextStyle(
                                color: _corStatus(ag['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        Text('Serviços: ${ag['servicos'].join(', ')}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.greenAccent),
                            const SizedBox(width: 6),
                            Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(ag['data'])),
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(width: 12),
                            const Icon(Icons.schedule, size: 16, color: Colors.amberAccent),
                            const SizedBox(width: 4),
                            Text(ag['horario'], style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${ag['valorTotal'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF47D178),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (ag['status'].toLowerCase() == 'pendente') ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final atualizado = Map<String, dynamic>.from(ag);
                                atualizado['status'] = 'Cancelado';

                                final response = await http.put(
                                  Uri.parse('http://localhost:3000/agendamentos/${ag['id']}'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode(atualizado),
                                );

                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Agendamento cancelado com sucesso.")),
                                  );
                                  carregarDados();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Erro ao cancelar agendamento.")),
                                  );
                                }
                              },
                              icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                              label: const Text("Cancelar Agendamento", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
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
