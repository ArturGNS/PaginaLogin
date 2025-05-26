class Agendamento {
  final String id;
  final String cliente;
  final String clienteEmail;
  final String barbeiro;
  final String barbeiroEmail;
  final List<String> servicos;
  final String data;
  final String horario;
  final double valorTotal;
  final String status;
  final int tempoTotal;

  Agendamento({
    required this.id,
    required this.cliente,
    required this.clienteEmail,
    required this.barbeiro,
    required this.barbeiroEmail,
    required this.servicos,
    required this.data,
    required this.horario,
    required this.valorTotal,
    required this.status,
    required this.tempoTotal,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      cliente: json['cliente'],
      clienteEmail: json['clienteEmail'],
      barbeiro: json['barbeiro'],
      barbeiroEmail: json['barbeiroEmail'],
      servicos: List<String>.from(json['servicos']),
      data: json['data'],
      horario: json['horario'],
      valorTotal: (json['valorTotal'] as num).toDouble(),
      status: json['status'],
      tempoTotal: json['tempoTotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'clienteEmail': clienteEmail,
      'barbeiro': barbeiro,
      'barbeiroEmail': barbeiroEmail,
      'servicos': servicos,
      'data': data,
      'horario': horario,
      'valorTotal': valorTotal,
      'status': status,
      'tempoTotal': tempoTotal,
    };
  }
}
