import 'package:flutter/material.dart';
import 'package:myapp/service/usuario_service.dart';

class UsuarioEditPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const UsuarioEditPage({Key? key, required this.usuario}) : super(key: key);

  @override
  State<UsuarioEditPage> createState() => _UsuarioEditPageState();
}

class _UsuarioEditPageState extends State<UsuarioEditPage> {
  late String tipoSelecionado;
  final List<String> tipos = ['cliente', 'funcionario', 'master'];

  @override
  void initState() {
    super.initState();
    tipoSelecionado = widget.usuario['tipo'] ?? 'cliente';
  }

  Future<void> _salvar() async {
    final sucesso = await UsuarioService()
        .atualizarUsuarioTipo(widget.usuario['id'].toString(), tipoSelecionado);

    if (sucesso) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao atualizar tipo do usuário")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Tipo de Usuário"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Nome: ${widget.usuario['nome']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Email: ${widget.usuario['email']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              decoration: const InputDecoration(labelText: "Tipo de Usuário"),
              items: tipos.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  tipoSelecionado = value!;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
