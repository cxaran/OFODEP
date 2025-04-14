import 'package:ofodep/models/abstract_model.dart';

// -- product_options
// -- Registra las opciones disponibles para cada configuración, incluyendo costos extras.
// CREATE TABLE product_options (
//     id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
//     store_id uuid REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
//     product_id uuid REFERENCES products(id) ON DELETE CASCADE NOT NULL,
//     product_configuration_id uuid REFERENCES product_configurations(id) ON DELETE CASCADE NOT NULL,
//     name text NOT NULL,
//     range_min int,
//     range_max int,
//     extra_price numeric DEFAULT 0,
//     position int DEFAULT 0,
//     created_at timestamptz DEFAULT now(),
//     updated_at timestamptz DEFAULT now(),
//     CHECK (range_min >= 0 AND range_max >= range_min)
// );

class ProductOptionModel extends ModelComponent {
  final String storeId;
  final String productId;
  final String configurationId;
  String name;
  int? rangeMin;
  int? rangeMax;
  num? extraPrice;
  int? position;

  ProductOptionModel({
    super.id,
    required this.storeId,
    required this.productId,
    required this.configurationId,
    required this.name,
    this.rangeMin,
    this.rangeMax,
    this.extraPrice,
    this.position,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductOptionModel.fromMap(Map<String, dynamic> map) {
    return ProductOptionModel(
      id: map['id'],
      storeId: map['store_id'],
      productId: map['product_id'],
      configurationId: map['product_configuration_id'],
      name: map['name'],
      rangeMin: map['range_min'],
      rangeMax: map['range_max'],
      extraPrice: map['extra_price'],
      position: map['position'],
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'store_id': storeId,
        'product_id': productId,
        'product_configuration_id': configurationId,
        'name': name,
        'range_min': rangeMin,
        'range_max': rangeMax,
        'extra_price': extraPrice,
        'position': position,
        'created_at': createdAt?.toIso8601String(),
      };

  @override
  ProductOptionModel copyWith({
    String? id,
    String? storeId,
    String? productId,
    String? configurationId,
    String? name,
    int? rangeMin,
    int? rangeMax,
    num? extraPrice,
    int? position,
  }) {
    return ProductOptionModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      configurationId: configurationId ?? this.configurationId,
      name: name ?? this.name,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      extraPrice: extraPrice ?? this.extraPrice,
      position: position ?? this.position,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'ProductOptionModel('
      'id: $id, '
      'storeId: $storeId, '
      'productId: $productId, '
      'configurationId: $configurationId, '
      'name: $name, '
      'rangeMin: $rangeMin, '
      'rangeMax: $rangeMax, '
      'extraPrice: $extraPrice, '
      'position: $position, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
