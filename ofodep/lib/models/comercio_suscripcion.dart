import 'enums.dart';

class ComercioSuscripcion {
  final String id;
  final String comercioId;
  final TipoSuscripcion tipoSuscripcion;
  final DateTime fechaExpiracion;
  DateTime createdAt;
  DateTime updatedAt;

  ComercioSuscripcion({
    required this.id,
    required this.comercioId,
    required this.tipoSuscripcion,
    required this.fechaExpiracion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComercioSuscripcion.fromMap(Map<String, dynamic> map) {
    return ComercioSuscripcion(
      id: map['id'] as String,
      comercioId: map['comercio_id'].toString(),
      tipoSuscripcion: TipoSuscripcionExtension.fromString(map['tipo_suscripcion']),
      fechaExpiracion: DateTime.parse(map['fecha_expiracion']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}