import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class ControleAgendamentosPage extends StatefulWidget {
  const ControleAgendamentosPage({Key? key}) : super(key: key);

  @override
  State<ControleAgendamentosPage> createState() => _ControleAgendamentosPageState();
}

class _ControleAgendamentosPageState extends State<ControleAgendamentosPage> {
  List<dynamic> todos = [];
  List<dynamic> filtrados = [];
  Set<DateTime> datasComAgendamento = {};
  String? barbeiroSelecionado;
  DateTime dataSelecionada = DateTime.now();

  final List<Map<String, String>> barbeiros = [
    {"nome": "Joao", "imagem": "assets/Joao_imagem.png"},
    {"nome": "Carlos", "imagem": "assets/Carlos_imagem.png"},
    {"nome": "Lucas", "imagem": "assets/Lucas_imagem.png"},
  ];

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  Future<void> carregarAgendamentos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/agendamentos'));
    if (response.statusCode == 200) {
      final List<dynamic> dados = json.decode(response.body);
      setState(() {
        todos = dados;
        atualizarDatasComAgendamento();
        filtrar();
      });
    }
  }

  void atualizarDatasComAgendamento() {
    final filtradosDatas = todos.where((ag) {
      return barbeiroSelecionado == null || ag['barbeiro'] == barbeiroSelecionado;
    });

    datasComAgendamento = filtradosDatas
        .map((a) => DateTime.parse(a['data']).toLocal())
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  void filtrar() {
    final f = DateFormat('yyyy-MM-dd');
    setState(() {
      filtrados = todos.where((a) {
        final matchBarbeiro = barbeiroSelecionado == null || a['barbeiro'] == barbeiroSelecionado;
        final matchData = a['data'].toString().split('T')[0] == f.format(dataSelecionada);
        return matchBarbeiro && matchData;
      }).toList();
    });
  }

  void abrirPopupEditarAgendamento(Map<String, dynamic> agendamento) {
    DateTime novaData = DateTime.tryParse(agendamento['data']) ?? DateTime.now();
    String? novoHorario = agendamento['horario'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D25),
          title: const Text("Remarcar Agendamento", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: novaData,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(primary: Color(0xFF47D178)),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => novaData = picked);
                  }
                },
                icon: const Icon(Icons.date_range),
                label: Text(DateFormat('dd/MM/yyyy').format(novaData)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C6E49)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: novoHorario,
                dropdownColor: const Color(0xFF1A1D25),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Horário",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                items: [
                  "09:00", "09:30", "10:00", "10:30",
                  "11:00", "11:30", "13:00", "13:30",
                  "14:00", "14:30", "15:00", "15:30"
                ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                onChanged: (val) => novoHorario = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final Map<String, dynamic> atualizado = Map.from(agendamento);
                atualizado['data'] = novaData.toIso8601String();
                atualizado['horario'] = novoHorario;
                await http.put(
                  Uri.parse('http://localhost:3000/agendamentos/${agendamento['id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(atualizado),
                );
                Navigator.pop(context);
                await carregarAgendamentos();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Agendamento atualizado"), backgroundColor: Color(0xFF47D178)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C6E49)),
              child: const Text("Salvar", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final barbeiroAtual = barbeiros.firstWhere(
      (b) => b['nome'] == barbeiroSelecionado,
      orElse: () => {},
    );

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
            'Controle de Agendamentos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: barbeiroSelecionado,
              decoration: InputDecoration(
                labelText: "Barbeiro",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1A1D25),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor: const Color(0xFF1A1D25),
              style: const TextStyle(color: Colors.white),
              items: [null, ...barbeiros.map((b) => b['nome'])]
                  .map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b ?? "Todos", style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => barbeiroSelecionado = val);
                atualizarDatasComAgendamento();
                filtrar();
              },
            ),
            if (barbeiroSelecionado != null && barbeiroAtual.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(barbeiroAtual['imagem']!),
                    radius: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(barbeiroAtual['nome']!, style: const TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                focusedDay: dataSelecionada,
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Color(0xFF2C6E49), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Color(0xFF47D178), shape: BoxShape.circle),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white70),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final isMarked = datasComAgendamento.contains(DateTime(date.year, date.month, date.day));
                    if (isMarked) {
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF47D178),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                selectedDayPredicate: (day) => isSameDay(day, dataSelecionada),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    dataSelecionada = selectedDay;
                    filtrar();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(
                      child: Text("Nenhum agendamento encontrado.", style: TextStyle(color: Colors.white70)),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: filtrados.map((ag) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Cliente: ${ag['cliente']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text("Barbeiro: ${ag['barbeiro']}", style: const TextStyle(color: Colors.white70)),
                              Text("Serviços: ${ag['servicos'].join(', ')}", style: const TextStyle(color: Colors.white70)),
                              Text("Horário: ${ag['horario']}", style: const TextStyle(color: Colors.white70)),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () => abrirPopupEditarAgendamento(ag),
                                    icon: const Icon(Icons.edit, color: Color(0xFF47D178)),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await http.delete(Uri.parse('http://localhost:3000/agendamentos/${ag['id']}'));
                                      await carregarAgendamentos();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Agendamento cancelado"), backgroundColor: Colors.red),
                                      );
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      }).toList(),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Sair", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
