class Agendamento {
  final String cliente;
  final String clienteEmail;
  final String barbeiro;
  final String barbeiroEmail;
  final List<String> servicos;
  final String horario;
  final String data;
  final double valorTotal;
  final String status; // ✅ NOVO CAMPO

  Agendamento({
    required this.cliente,
    required this.clienteEmail,
    required this.barbeiro,
    required this.barbeiroEmail,
    required this.servicos,
    required this.horario,
    required this.data,
    required this.valorTotal,
    required this.status, // ✅ NOVO CAMPO
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      cliente: json['cliente'],
      clienteEmail: json['clienteEmail'],
      barbeiro: json['barbeiro'],
      barbeiroEmail: json['barbeiroEmail'],
      servicos: List<String>.from(json['servicos']),
      horario: json['horario'],
      data: json['data'],
      valorTotal: (json['valorTotal'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pendente', // ✅ fallback se faltar
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente': cliente,
      'clienteEmail': clienteEmail,
      'barbeiro': barbeiro,
      'barbeiroEmail': barbeiroEmail,
      'servicos': servicos,
      'horario': horario,
      'data': data,
      'valorTotal': valorTotal,
      'status': status, // ✅ incluído
    };
  }
}
