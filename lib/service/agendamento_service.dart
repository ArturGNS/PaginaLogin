import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/agendamento_model.dart';

class AgendamentoService {
  final String baseUrl = 'http://localhost:3000/agendamentos';

  // Criar um novo agendamento
  Future<bool> criarAgendamento(Agendamento agendamento) async {
    final resposta = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agendamento.toJson()),
    );
    return resposta.statusCode == 201 || resposta.statusCode == 200;
  }

  // Listar todos os agendamentos
  Future<List<Agendamento>> listarAgendamentos() async {
    final resposta = await http.get(Uri.parse(baseUrl));
    if (resposta.statusCode == 200) {
      final List data = jsonDecode(resposta.body);
      return data.map((e) => Agendamento.fromJson(e)).toList();
    } else {
      throw Exception("Erro ao carregar agendamentos");
    }
  }

  // Listar agendamentos filtrando por barbeiro
  Future<List<Agendamento>> listarPorBarbeiro(String barbeiroNome) async {
    final url = Uri.parse('$baseUrl?barbeiro=$barbeiroNome');
    final resposta = await http.get(url);
    if (resposta.statusCode == 200) {
      final List data = jsonDecode(resposta.body);
      return data.map((e) => Agendamento.fromJson(e)).toList();
    } else {
      throw Exception("Erro ao buscar agendamentos do barbeiro");
    }
  }
}
