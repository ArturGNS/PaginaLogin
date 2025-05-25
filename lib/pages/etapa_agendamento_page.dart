import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:myapp/pages/main_cliente_page.dart';

class EtapaAgendamentoPage extends StatefulWidget {
  final String clienteNome;
  final String clienteEmail;
  final String barbeiroNome;
  final String barbeiroEmail;
  final List<String> servicosSelecionados;
  final String statusInicial;

  const EtapaAgendamentoPage({
    super.key,
    required this.clienteNome,
    required this.clienteEmail,
    required this.barbeiroNome,
    required this.barbeiroEmail,
    required this.servicosSelecionados,
    required this.statusInicial,
  });

  @override
  State<EtapaAgendamentoPage> createState() => _EtapaAgendamentoPageState();
}

class _EtapaAgendamentoPageState extends State<EtapaAgendamentoPage> {
  DateTime? dataSelecionada;
  String? horarioSelecionado;

  final List<String> horarios = [
    "09:00", "09:30", "10:00", "10:30", "11:00",
    "11:30", "13:00", "13:30", "14:00", "14:30",
    "15:00", "15:30"
  ];

  final Map<String, Map<String, dynamic>> servicoData = {
    "Barba": {"preco": 30.0},
    "Sobrancelha": {"preco": 15.0},
    "Degrade": {"preco": 30.0},
    "Nevou": {"preco": 100.0},
    "Social": {"preco": 30.0},
  };

  @override
  Widget build(BuildContext context) {
    final double valorTotal = widget.servicosSelecionados.fold(0.0, (sum, nome) {
      final servico = servicoData[nome];
      return sum + (servico?['preco'] ?? 0.0);
    });

    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Confirmar Agendamento",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C6E49),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Serviços escolhidos:", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 6),
                        ...widget.servicosSelecionados.map(
                          (s) => Text("- $s", style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Total: ${formatador.format(valorTotal)}",
                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage("assets/Lucas_imagem.png"),
                        radius: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(widget.barbeiroNome, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: dataSelecionada ?? DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(dataSelecionada, day),
                onDaySelected: (selectedDay, _) {
                  setState(() {
                    dataSelecionada = selectedDay;
                    horarioSelecionado = null;
                  });
                },
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (dataSelecionada != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Horários disponíveis:", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: horarios.map((hora) {
                  final selecionado = hora == horarioSelecionado;
                  return GestureDetector(
                    onTap: () => setState(() => horarioSelecionado = hora),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selecionado ? Colors.greenAccent : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hora,
                        style: TextStyle(
                          color: selecionado ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (dataSelecionada != null && horarioSelecionado != null)
                    ? _confirmarAgendamento
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
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
    );
  }

  Future<void> _confirmarAgendamento() async {
    final double valorTotal = widget.servicosSelecionados.fold(0.0, (sum, nome) {
      final servico = servicoData[nome];
      return sum + (servico?['preco'] ?? 0.0);
    });

    final agendamento = {
      "cliente": widget.clienteNome,
      "clienteEmail": widget.clienteEmail,
      "barbeiro": widget.barbeiroNome,
      "barbeiroEmail": widget.barbeiroEmail,
      "servicos": widget.servicosSelecionados,
      "data": dataSelecionada!.toIso8601String(),
      "horario": horarioSelecionado!,
      "valorTotal": valorTotal,
      "status": widget.statusInicial,
    };

    final response = await http.post(
      Uri.parse("http://localhost:3000/agendamentos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(agendamento),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento realizado com sucesso!")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainClientePage(
            clienteNome: widget.clienteNome,
            clienteEmail: widget.clienteEmail,
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao realizar agendamento.")),
      );
    }
  }
}
