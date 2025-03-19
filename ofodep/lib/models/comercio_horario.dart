class ComercioHorario {
  final String id;
  final String comercioId;
  final List<int> dias; // Ej: [1,2,3,4,5] (1 = lunes, ... , 7 = domingo)
  final String horaApertura;
  final String horaCierre;
  DateTime createdAt;
  DateTime updatedAt;

  ComercioHorario({
    required this.id,
    required this.comercioId,
    required this.dias,
    required this.horaApertura,
    required this.horaCierre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComercioHorario.fromMap(Map<String, dynamic> map) {
    List<dynamic> diasDynamic = map['dias'] as List<dynamic>;
    List<int> dias = diasDynamic.map((e) => int.parse(e.toString())).toList();

    return ComercioHorario(
      id: map['id'] as String,
      comercioId: map['comercio_id'].toString(),
      dias: dias,
      horaApertura: map['hora_apertura'].toString(),
      horaCierre: map['hora_cierre'].toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}