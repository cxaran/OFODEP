class ComercioHorarioExcepcion {
  final String id;
  final String comercioId;
  final DateTime fecha;
  final bool esCerrado;
  final String? horaApertura;
  final String? horaCierre;
  DateTime createdAt;
  DateTime updatedAt;

  ComercioHorarioExcepcion({
    required this.id,
    required this.comercioId,
    required this.fecha,
    required this.esCerrado,
    this.horaApertura,
    this.horaCierre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComercioHorarioExcepcion.fromMap(Map<String, dynamic> map) {
    return ComercioHorarioExcepcion(
      id: map['id'] as String,
      comercioId: map['comercio_id'].toString(),
      fecha: DateTime.parse(map['fecha']),
      esCerrado: map['es_cerrado'] as bool? ?? false,
      horaApertura: map['hora_apertura']?.toString(),
      horaCierre: map['hora_cierre']?.toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}