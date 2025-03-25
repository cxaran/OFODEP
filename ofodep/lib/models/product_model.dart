import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/product_configuration_model.dart';

class ProductModel extends ModelComponent {
  final String storeId;
  final String storeName;
  String name;
  String? description;
  String? imageUrl;
  num? price;
  String? category;
  List<String>? tags;

  List<ProductConfigurationModel> configurations;

  ProductModel({
    required super.id,
    required this.storeId,
    required this.storeName,
    required this.name,
    this.description,
    this.imageUrl,
    this.price,
    this.category,
    this.tags,
    super.createdAt,
    super.updatedAt,
    this.configurations = const [],
  });

  @override
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
        'image_url': imageUrl,
        'price': price,
        'category': category,
        'tags': tags,
      };

  @override
  ProductModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    num? price,
    String? category,
    List<String>? tags,
    List<ProductConfigurationModel>? configurations,
  }) {
    return ProductModel(
      id: id,
      storeId: storeId,
      storeName: storeName,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      configurations: configurations ?? this.configurations,
    );
  }

  @override
  String toString() => 'ProductModel('
      'id: $id, '
      'storeId: $storeId, '
      'storeName: $storeName, '
      'name: $name, '
      'description: $description, '
      'imageUrl: $imageUrl, '
      'price: $price, '
      'category: $category, '
      'tags: $tags, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'configurations: $configurations'
      ')';
}
