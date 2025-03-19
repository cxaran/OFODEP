class ComercioZona {
  final String id;
  final String comercioId;
  final String zonaId;
  DateTime createdAt;
  DateTime updatedAt;

  ComercioZona({
    required this.id,
    required this.comercioId,
    required this.zonaId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComercioZona.fromMap(Map<String, dynamic> map) {
    return ComercioZona(
      id: map['id'] as String,
      comercioId: map['comercio_id'].toString(),
      zonaId: map['zona_id'].toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}