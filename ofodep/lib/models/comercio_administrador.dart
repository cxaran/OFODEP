class ComercioAdministrador {
  final String id;
  final String comercioId;
  final String usuarioId;
  DateTime createdAt;
  DateTime updatedAt;

  ComercioAdministrador({
    required this.id,
    required this.comercioId,
    required this.usuarioId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComercioAdministrador.fromMap(Map<String, dynamic> map) {
    return ComercioAdministrador(
      id: map['id'] as String,
      comercioId: map['comercio_id'].toString(),
      usuarioId: map['usuario_id'].toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}