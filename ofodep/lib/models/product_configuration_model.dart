import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/product_option_model.dart';

class ProductConfigurationModel extends ModelComponent {
  final String productId;
  String name;
  int rangeMin;
  int rangeMax;

  List<ProductOptionModel> options;

  ProductConfigurationModel({
    required super.id,
    required this.productId,
    required this.name,
    required this.rangeMin,
    required this.rangeMax,
    super.createdAt,
    super.updatedAt,
    this.options = const [],
  });

  @override
  factory ProductConfigurationModel.fromMap(Map<String, dynamic> map) {
    return ProductConfigurationModel(
      id: map['id'],
      productId: map['product_id'],
      name: map['name'],
      rangeMin: map['range_min'],
      rangeMax: map['range_max'],
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
        'product_id': productId,
        'name': name,
        'range_min': rangeMin,
        'range_max': rangeMax,
      };

  @override
  ProductConfigurationModel copyWith({
    String? name,
    int? rangeMin,
    int? rangeMax,
    List<ProductOptionModel>? options,
  }) {
    return ProductConfigurationModel(
      id: id,
      productId: productId,
      name: name ?? this.name,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      createdAt: createdAt,
      updatedAt: updatedAt,
      options: options ?? this.options,
    );
  }

  @override
  String toString() => 'ProductConfigurationModel(id: $id, '
      'productId'
      ': $productId, '
      'name'
      ': $name, '
      'rangeMin'
      ': $rangeMin, '
      'rangeMax'
      ': $rangeMax, '
      'createdAt'
      ': $createdAt, '
      'updatedAt'
      ': $updatedAt, '
      'options'
      ': $options)';
}
