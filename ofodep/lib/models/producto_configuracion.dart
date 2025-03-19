class ProductoConfiguracion {
  final String id;
  final String productoId;
  String nombre;
  int? rangoMin;
  int? rangoMax;
  DateTime createdAt;
  DateTime updatedAt;

  ProductoConfiguracion({
    required this.id,
    required this.productoId,
    required this.nombre,
    this.rangoMin,
    this.rangoMax,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductoConfiguracion.fromMap(Map<String, dynamic> map) {
    return ProductoConfiguracion(
      id: map['id'] as String,
      productoId: map['producto_id'].toString(),
      nombre: map['nombre'].toString(),
      rangoMin: map['rango_min'] as int?,
      rangoMax: map['rango_max'] as int?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}