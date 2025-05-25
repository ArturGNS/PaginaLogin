import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  final String baseUrl = 'http://localhost:3000';

  // Cadastrar novo usuário como cliente por padrão
  Future<bool> cadastrarUsuario(String nome, String email, String senha, String dataNascimento, String tipo)
 async {
    final url = Uri.parse('$baseUrl/usuarios');

    final resposta = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'dataNascimento': dataNascimento,
        'tipo': tipo
      }),

    );

    return resposta.statusCode == 201 || resposta.statusCode == 200;
  }

  // Verifica login e retorna dados completos do usuário se existir
  Future<Map<String, dynamic>?> verificarLogin(String email, String senha) async {
    final url = Uri.parse('$baseUrl/usuarios?email=$email&senha=$senha');

    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      final List usuarios = jsonDecode(resposta.body);
      if (usuarios.isNotEmpty) return usuarios[0];
    }
    return null;
  }

  // Atualiza senha com base no email
  Future<bool> atualizarSenha(String email, String novaSenha) async {
    final urlBusca = Uri.parse('$baseUrl/usuarios?email=$email');
    final resposta = await http.get(urlBusca);

    if (resposta.statusCode == 200) {
      final List usuarios = jsonDecode(resposta.body);
      if (usuarios.isNotEmpty) {
        final id = usuarios[0]['id'].toString(); // força ID como String
        final urlUpdate = Uri.parse('$baseUrl/usuarios/$id');

        final respostaUpdate = await http.put(
          urlUpdate,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            ...usuarios[0],
            'senha': novaSenha,
          }),
        );

        return respostaUpdate.statusCode == 200;
      }
    }
    return false;
  }

  // Lista todos os usuários cadastrados
  Future<List<dynamic>> listarUsuarios() async {
    final url = Uri.parse('$baseUrl/usuarios');
    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      return jsonDecode(resposta.body);
    } else {
      throw Exception("Erro ao carregar usuários");
    }
  }

  // Atualiza o tipo de usuário (cliente, funcionario, master)
  Future<bool> atualizarUsuarioTipo(String id, String novoTipo) async {
    final urlBusca = Uri.parse('$baseUrl/usuarios/$id');
    final resposta = await http.get(urlBusca);

    if (resposta.statusCode != 200) return false;

    final usuario = jsonDecode(resposta.body);

    final respostaUpdate = await http.put(
      urlBusca,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...usuario,
        'tipo': novoTipo,
      }),
    );

    return respostaUpdate.statusCode == 200;
  }
}
