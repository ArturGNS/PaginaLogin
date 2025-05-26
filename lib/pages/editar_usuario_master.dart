import 'package:flutter/material.dart';
import 'package:myapp/service/usuario_service.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({Key? key}) : super(key: key);

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<dynamic> usuarios = [];

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    final lista = await UsuarioService().listarUsuarios();
    setState(() {
      usuarios = lista;
    });
  }

  void _editarTipoUsuario(dynamic usuario) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String tipoSelecionado = usuario['tipo'];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Editar Tipo de Usuário",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: tipoSelecionado,
                decoration: InputDecoration(
                  labelText: "Tipo",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                dropdownColor: const Color(0xFF2C2C2C),
                style: const TextStyle(color: Colors.white),
                items: ['cliente', 'funcionario', 'master'].map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo[0].toUpperCase() + tipo.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => tipoSelecionado = value!);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C6E49),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final sucesso = await UsuarioService()
                        .atualizarUsuarioTipo(usuario['id'].toString(), tipoSelecionado);
                    Navigator.pop(context);
                    if (sucesso) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tipo atualizado com sucesso!")),
                      );
                      carregarUsuarios();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro ao atualizar o tipo.")),
                      );
                    }
                  },
                  child: const Text("Salvar", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1C2F25),
        centerTitle: true,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C6E49),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Usuários Cadastrados",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: usuarios.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final usuario = usuarios[index];
                  final String imagemPath = 'assets/${usuario['nome']}_imagem.png';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(imagemPath),
                          backgroundColor: Colors.grey[700],
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(height: 10),
                        Text(usuario['nome'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(usuario['email'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text("Nascimento: ${usuario['dataNascimento']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Text("Senha: ${usuario['senha']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Text("Tipo: ${usuario['tipo']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () => _editarTipoUsuario(usuario),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Sair", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
