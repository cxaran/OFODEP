abstract class ModelComponent {
  final String id;
  DateTime? createdAt;
  DateTime? updatedAt;

  ModelComponent({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// Crear una instancia del objeto a partir de un mapa (por ejemplo, desde JSON)
  /// [map] mapa de datos
  ModelComponent.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.tryParse(map['created_at'] ?? ''),
        updatedAt = DateTime.tryParse(map['updated_at'] ?? '');

  /// Convertir el objeto en un mapa para guardarlo en JSON o base de datos
  Map<String, dynamic> toMap({bool includeId = true});

  /// Crear una copia del objeto con modificaciones
  ModelComponent copyWith({String? id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelComponent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '${runtimeType.toString()}(id: $id)';
}
