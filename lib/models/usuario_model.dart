class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senha;
  final String tipo; // 'cliente', 'funcionario', 'master'
  final String? dataNascimento;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipo,
    this.dataNascimento,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
      tipo: json['tipo'],
      dataNascimento: json['dataNascimento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipo': tipo,
      'dataNascimento': dataNascimento,
    };
  }
}
