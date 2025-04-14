import 'package:ofodep/models/abstract_model.dart';

class ProductsCategoryModel extends ModelComponent {
  final String storeId;
  String? storeName;
  String name;
  String? description;
  int? position;

  ProductsCategoryModel({
    super.id,
    required this.storeId,
    this.storeName,
    required this.name,
    this.description,
    this.position,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductsCategoryModel.fromMap(Map<String, dynamic> map) {
    return ProductsCategoryModel(
      id: map['id'],
      storeId: map['store_id'],
      storeName: map['stores']['name'],
      name: map['name'],
      description: map['description'],
      position: map['position'],
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({
    bool includeId = true,
  }) =>
      {
        if (includeId) 'id': id,
        'store_id': storeId,
        'name': name,
        'description': description,
        'position': position,
      };

  @override
  ProductsCategoryModel copyWith({
    String? id,
    String? storeId,
    String? storeName,
    String? name,
    String? description,
    int? position,
  }) {
    return ProductsCategoryModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'ProductsCategoryModel(id: $id, '
      'storeId: $storeId, '
      'storeName: $storeName, '
      'name: $name, '
      'description: $description, '
      'position: $position, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
