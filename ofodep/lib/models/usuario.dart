class Usuario {
  final String id;
  final String authId;
  String nombre;
  String email;
  String telefono;
  bool admin;
  DateTime createdAt;
  DateTime updatedAt;

  Usuario({
    required this.id,
    required this.authId,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.admin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as String,
      authId: map['auth_id'].toString(),
      nombre: map['nombre'].toString(),
      email: map['email'].toString(),
      telefono: map['telefono'].toString(),
      admin: map['admin'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}