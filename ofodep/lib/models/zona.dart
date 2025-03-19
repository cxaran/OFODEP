class Zona {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? geom;
  final List<String>? codigosPostales;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Zona({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.geom,
    this.codigosPostales,
    this.createdAt,
    this.updatedAt,
  });

  factory Zona.fromMap(Map<String, dynamic> map) {
    return Zona(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      geom: map['geom'],
      codigosPostales: (map['codigos_postales'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
