import 'package:ofodep/models/abstract_model.dart';

class ProductOptionModel extends ModelComponent {
  final String configurationId;
  String name;
  int optionMin;
  int optionMax;
  num extraPrice;

  ProductOptionModel({
    required super.id,
    required this.configurationId,
    required this.name,
    required this.optionMin,
    required this.optionMax,
    required this.extraPrice,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductOptionModel.fromMap(Map<String, dynamic> map) {
    return ProductOptionModel(
      id: map['id'],
      configurationId: map['configuration_id'],
      name: map['name'],
      optionMin: map['option_min'],
      optionMax: map['option_max'],
      extraPrice: map['extra_price'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toMap({
    bool includeId = true,
  }) =>
      {
        if (includeId) 'id': id,
        'configuration_id': configurationId,
        'name': name,
        'option_min': optionMin,
        'option_max': optionMax,
        'extra_price': extraPrice,
      };

  @override
  ProductOptionModel copyWith({
    String? name,
    int? optionMin,
    int? optionMax,
    num? extraPrice,
  }) {
    return ProductOptionModel(
      id: id,
      configurationId: configurationId,
      name: name ?? this.name,
      optionMin: optionMin ?? this.optionMin,
      optionMax: optionMax ?? this.optionMax,
      extraPrice: extraPrice ?? this.extraPrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'ProductOptionModel(id: $id, '
      'configurationId: $configurationId, '
      'name: $name, '
      'optionMin: $optionMin, '
      'optionMax: $optionMax, '
      'extraPrice: $extraPrice, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
