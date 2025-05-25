import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class GerenciarServicosPage extends StatefulWidget {
  const GerenciarServicosPage({Key? key}) : super(key: key);

  @override
  State<GerenciarServicosPage> createState() => _GerenciarServicosPageState();
}

class _GerenciarServicosPageState extends State<GerenciarServicosPage> {
  List<dynamic> servicos = [];

  @override
  void initState() {
    super.initState();
    carregarServicos();
  }

  Future<void> carregarServicos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/servicos'));
    if (response.statusCode == 200) {
      setState(() {
        servicos = json.decode(response.body);
      });
    }
  }

  Future<void> deletarServico(String id) async {
    await http.delete(Uri.parse('http://localhost:3000/servicos/$id'));
    await carregarServicos();
  }

  void abrirModalAdicionarOuEditar({Map<String, dynamic>? servicoExistente}) async {
    final TextEditingController nomeController = TextEditingController(
        text: servicoExistente != null ? servicoExistente['nome'] : '');
    final TextEditingController precoController = TextEditingController(
        text: servicoExistente != null ? servicoExistente['preco'].toString() : '');
    final TextEditingController tempoController = TextEditingController(
        text: servicoExistente != null ? servicoExistente['tempo'].toString() : '');
    String? imagemPath = servicoExistente != null ? servicoExistente['imagem'] : null;
    File? imagemFile;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(servicoExistente != null ? 'Editar Serviço' : 'Novo Serviço',
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome do serviço"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: precoController,
                decoration: const InputDecoration(labelText: "Preço"),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: tempoController,
                decoration: const InputDecoration(labelText: "Duração em minutos"),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );
                  if (result != null) {
                    imagemFile = File(result.files.single.path!);
                    final nomeArquivo = "${nomeController.text}_imagem.png".replaceAll(" ", "");
                    final novoPath = 'assets/$nomeArquivo';
                    imagemPath = novoPath;
                    // Salvar localmente (simulação de upload)
                    await imagemFile!.copy(novoPath);
                    setState(() {}); // Atualiza preview se necessário
                  }
                },
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text("Selecionar Imagem", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () async {
              final nome = nomeController.text;
              final preco = double.tryParse(precoController.text) ?? 0;
              final tempo = int.tryParse(tempoController.text) ?? 0;

              final Map<String, dynamic> novoServico = {
                "nome": nome,
                "preco": preco,
                "tempo": tempo,
                "imagem": imagemPath ?? "",
              };

              if (servicoExistente != null) {
                await http.put(
                  Uri.parse('http://localhost:3000/servicos/${servicoExistente['id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(novoServico),
                );
              } else {
                await http.post(
                  Uri.parse('http://localhost:3000/servicos'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(novoServico),
                );
              }

              Navigator.pop(context);
              await carregarServicos();
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Gerenciar Serviços"),
        backgroundColor: Colors.green.shade700.withOpacity(0.9),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: servicos.length,
          itemBuilder: (context, index) {
            final servico = servicos[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        servico['imagem'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.image_not_supported, color: Colors.white30)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(servico["nome"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("R\$ ${servico["preco"].toStringAsFixed(2)}", style: const TextStyle(color: Colors.white70)),
                        Text("${servico["tempo"]} min", style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => abrirModalAdicionarOuEditar(servicoExistente: servico),
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: () => deletarServico(servico['id'].toString()),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => abrirModalAdicionarOuEditar(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
