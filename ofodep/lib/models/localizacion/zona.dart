class Zona {
  final String id;
  final String nombre;
  final String descripcion;
  final List<String> codigosPostales;
  final DateTime createdAt;
  final DateTime updatedAt;

  Zona({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.codigosPostales,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Zona.fromMap(Map<String, dynamic> map) {
    return Zona(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      codigosPostales: map['codigos_postales'] as List<String>,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
