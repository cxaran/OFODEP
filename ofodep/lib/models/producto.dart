class Producto {
  final String id;
  final String comercioId;
  String nombre;
  String? descripcion;
  String? imagenUrl;
  num? precio;
  String? categoria;
  List<String>? tags;
  DateTime createdAt;
  DateTime updatedAt;

  Producto({
    required this.id,
    required this.comercioId,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    this.precio,
    this.categoria,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as String,
      comercioId: map['comercio_id'].toString(),
      nombre: map['nombre'].toString(),
      descripcion: map['descripcion'] as String?,
      imagenUrl: map['imagen_url'] as String?,
      precio: map['precio'],
      categoria: map['categoria'] as String?,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}