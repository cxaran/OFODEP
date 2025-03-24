class ProductModel {
  final String id;
  final String storeId;
  final String storeName;
  String name;
  String? description;
  String? imageUrl;
  num? price;
  String? category;
  List<String>? tags;
  DateTime createdAt;
  DateTime updatedAt;

  List<ProductConfigurationModel> configurations;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.name,
    this.description,
    this.imageUrl,
    this.price,
    this.category,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.configurations = const [],
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      storeId: map['store_id'],
      storeName: map['stores']?['name'] ?? '',
      name: map['name'],
      description: map['description'],
      imageUrl: map['image_url'],
      price: map['price'],
      category: map['category'],
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class ProductConfigurationModel {
  final String id;
  final String productId;
  String name;
  int rangeMin;
  int rangeMax;
  DateTime createdAt;
  DateTime updatedAt;

  // Relaciones
  List<ProductOptionModel> options;

  ProductConfigurationModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.rangeMin,
    required this.rangeMax,
    required this.createdAt,
    required this.updatedAt,
    this.options = const [],
  });

  factory ProductConfigurationModel.fromMap(Map<String, dynamic> map) {
    return ProductConfigurationModel(
      id: map['id'],
      productId: map['product_id'],
      name: map['name'],
      rangeMin: map['range_min'],
      rangeMax: map['range_max'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'range_min': rangeMin,
        'range_max': rangeMax,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class ProductOptionModel {
  final String id;
  final String configurationId;
  String name;
  int optionMin;
  int optionMax;
  num extraPrice;
  DateTime createdAt;
  DateTime updatedAt;

  ProductOptionModel({
    required this.id,
    required this.configurationId,
    required this.name,
    required this.optionMin,
    required this.optionMax,
    required this.extraPrice,
    required this.createdAt,
    required this.updatedAt,
  });

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'configuration_id': configurationId,
        'name': name,
        'option_min': optionMin,
        'option_max': optionMax,
        'extra_price': extraPrice,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
