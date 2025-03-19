class ProductoOpcion {
  final String id;
  final String configuracionId;
  String nombre;
  int? opcionMin;
  int? opcionMax;
  num precioExtra;
  DateTime createdAt;
  DateTime updatedAt;

  ProductoOpcion({
    required this.id,
    required this.configuracionId,
    required this.nombre,
    this.opcionMin,
    this.opcionMax,
    this.precioExtra = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductoOpcion.fromMap(Map<String, dynamic> map) {
    return ProductoOpcion(
      id: map['id'] as String,
      configuracionId: map['configuracion_id'].toString(),
      nombre: map['nombre'].toString(),
      opcionMin: map['opcion_min'] as int?,
      opcionMax: map['opcion_max'] as int?,
      precioExtra: map['precio_extra'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}