import 'package:ofodep/models/abstract_model.dart';

class ProductModel extends ModelComponent {
  final String storeId;
  String name;
  String? description;
  String? imageUrl;
  num regularPrice;
  num? salePrice;
  DateTime? saleStart;
  DateTime? saleEnd;
  String? currency;
  String? category;
  List<String>? tags;
  bool active;
  int position;

  ProductModel({
    required super.id,
    required this.storeId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.regularPrice,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    this.currency,
    this.category,
    this.tags,
    this.active = true,
    this.position = 0,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      storeId: map['store_id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['image_url'],
      regularPrice: map['regular_price'],
      salePrice: map['sale_price'],
      saleStart: map['sale_start'],
      saleEnd: map['sale_end'],
      currency: map['currency'],
      category: map['category'],
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList(),
      active: map['active'],
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
        'image_url': imageUrl,
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'sale_start': saleStart,
        'sale_end': saleEnd,
        'currency': currency,
        'category': category,
        'tags': tags,
        'active': active,
        'position': position,
      };

  @override
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    num? regularPrice,
    num? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
    String? currency,
    String? category,
    List<String>? tags,
    bool? active,
    int? position,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      saleStart: saleStart ?? this.saleStart,
      saleEnd: saleEnd ?? this.saleEnd,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      active: active ?? this.active,
      position: position ?? this.position,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'ProductModel(id: $id, '
      'storeId: $storeId, '
      'name: $name, '
      'description: $description, '
      'imageUrl: $imageUrl, '
      'regularPrice: $regularPrice, '
      'salePrice: $salePrice, '
      'saleStart: $saleStart, '
      'saleEnd: $saleEnd, '
      'currency: $currency, '
      'category: $category, '
      'tags: $tags, '
      'active: $active, '
      'position: $position, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
