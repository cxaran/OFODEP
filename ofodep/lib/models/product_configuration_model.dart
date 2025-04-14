import 'package:ofodep/models/abstract_model.dart';

class ProductConfigurationModel extends ModelComponent {
  final String storeId;
  final String productId;
  final String name;
  final String? description;
  final int? rangeMin;
  final int? rangeMax;
  final int? position;

  ProductConfigurationModel({
    super.id,
    required this.storeId,
    required this.productId,
    required this.name,
    this.description,
    this.rangeMin,
    this.rangeMax,
    this.position,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductConfigurationModel.fromMap(Map<String, dynamic> map) {
    return ProductConfigurationModel(
      id: map['id'],
      storeId: map['store_id'],
      productId: map['product_id'],
      name: map['name'],
      description: map['description'],
      rangeMin: map['range_min'],
      rangeMax: map['range_max'],
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
        'product_id': productId,
        'name': name,
        'description': description,
        'range_min': rangeMin,
        'range_max': rangeMax,
        'position': position,
        'created_at': createdAt?.toIso8601String(),
      };

  @override
  ProductConfigurationModel copyWith({
    String? id,
    String? storeId,
    String? productId,
    String? name,
    String? description,
    int? rangeMin,
    int? rangeMax,
    int? position,
  }) {
    return ProductConfigurationModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      position: position ?? this.position,
      updatedAt: updatedAt,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'ProductConfigurationModel('
      'id: $id, '
      'storeId: $storeId, '
      'productId: $productId, '
      'name: $name, '
      'description: $description, '
      'rangeMin: $rangeMin, '
      'rangeMax: $rangeMax, '
      'position: $position, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
