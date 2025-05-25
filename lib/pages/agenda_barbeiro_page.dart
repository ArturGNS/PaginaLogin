import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaBarbeiroPage extends StatefulWidget {
  final Map<String, dynamic> usuarioLogado;

  const AgendaBarbeiroPage({Key? key, required this.usuarioLogado}) : super(key: key);

  @override
  _AgendaBarbeiroPageState createState() => _AgendaBarbeiroPageState();
}

class _AgendaBarbeiroPageState extends State<AgendaBarbeiroPage> {
  List<dynamic> todosAgendamentos = [];
  List<dynamic> agendamentosFiltrados = [];
  DateTime dataSelecionada = DateTime.now();
  Map<String, List<dynamic>> eventosPorData = {};

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  Future<void> carregarAgendamentos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/agendamentos'));

    if (response.statusCode == 200) {
      final List<dynamic> dados = json.decode(response.body);

      final List<dynamic> doBarbeiro = dados.where((agendamento) {
        return agendamento['barbeiroEmail'] == widget.usuarioLogado['email'];
      }).toList();

      final Map<String, List<dynamic>> agrupado = {};

      for (var ag in doBarbeiro) {
        String data = ag['data'].toString().split('T')[0];
        agrupado[data] = agrupado[data] ?? [];
        agrupado[data]!.add(ag);
      }

      setState(() {
        todosAgendamentos = doBarbeiro;
        eventosPorData = agrupado;
        filtrarPorData();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar agendamentos')),
      );
    }
  }

  void filtrarPorData() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final dataStr = formatter.format(dataSelecionada);

    setState(() {
      agendamentosFiltrados = eventosPorData[dataStr] ?? [];
    });
  }

  Future<void> atualizarStatus(dynamic agendamento, String novoStatus) async {
    final url = Uri.parse('http://localhost:3000/agendamentos/${agendamento['id']}');

    final atualizado = Map<String, dynamic>.from(agendamento);
    atualizado['status'] = novoStatus;

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(atualizado),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para "$novoStatus"')),
      );
      carregarAgendamentos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C6E49),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Minha Agenda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        leading: const Icon(Icons.calendar_month, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                focusedDay: dataSelecionada,
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.white24),
                  todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                selectedDayPredicate: (day) => isSameDay(day, dataSelecionada),
                onDaySelected: (selectedDay, _) {
                  setState(() {
                    dataSelecionada = selectedDay;
                    filtrarPorData();
                  });
                },
                eventLoader: (day) {
                  final dataStr = DateFormat('yyyy-MM-dd').format(day);
                  return eventosPorData[dataStr] ?? [];
                },
              ),
            ),
            const SizedBox(height: 10),
            if (agendamentosFiltrados.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${agendamentosFiltrados.length} agendamento(s) no dia ${DateFormat('dd/MM/yyyy').format(dataSelecionada)}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            Expanded(
              child: agendamentosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum agendamento para essa data.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: agendamentosFiltrados.length,
                      itemBuilder: (context, index) {
                        final agendamento = agendamentosFiltrados[index];
                        return Card(
                          color: const Color(0xFF1A1A1A),
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: ListTile(
                            title: Text(
                              agendamento['cliente'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  'Serviços: ${agendamento['servicos'].join(', ')}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Horário: ${agendamento['horario']}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Status: ${agendamento['status'] ?? 'Pendente'}',
                                  style: TextStyle(
                                    color: (agendamento['status'] ?? '') == 'Concluido'
                                        ? Colors.greenAccent
                                        : (agendamento['status'] ?? '') == 'Cancelado'
                                            ? Colors.redAccent
                                            : Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (agendamento['status'] != 'Concluido')
                                      TextButton(
                                        onPressed: () => atualizarStatus(agendamento, 'Concluido'),
                                        child: const Text('Marcar como Concluido', style: TextStyle(color: Colors.greenAccent)),
                                      ),
                                    if (agendamento['status'] != 'Cancelado')
                                      TextButton(
                                        onPressed: () => atualizarStatus(agendamento, 'Cancelado'),
                                        child: const Text('Cancelar Agendamento', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text("Voltar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
