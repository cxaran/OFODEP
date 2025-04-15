import 'package:ofodep/models/abstract_model.dart';

class ProductModel extends ModelComponent {
  final String storeId;
  String? categoryId;
  String? storeName;
  String? storeTimezone;
  String? categoryName;
  String? name;
  String? description;
  String? imageUrl;
  num? productPrice;
  num? regularPrice;
  num? salePrice;
  DateTime? saleStart;
  DateTime? saleEnd;
  String? currency;
  List<String> tags;
  List<int> days;
  bool active;
  int? position;

  ProductModel({
    super.id,
    required this.storeId,
    this.categoryId,
    this.storeName,
    this.storeTimezone,
    this.categoryName,
    this.name,
    this.description,
    this.imageUrl,
    this.productPrice,
    this.regularPrice,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    this.currency,
    this.tags = const [],
    this.days = const [],
    this.active = true,
    this.position,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      storeId: map['store_id'],
      categoryId: map['category_id'],
      storeName: map['stores']?['name'],
      storeTimezone: map['stores']?['timezone'],
      categoryName: map['products_categories']?['name'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['image_url'],
      productPrice: map['product_price'],
      regularPrice: map['regular_price'],
      salePrice: map['sale_price'],
      saleStart: DateTime.tryParse(map['sale_start'] ?? ''),
      saleEnd: DateTime.tryParse(map['sale_end'] ?? ''),
      currency: map['currency'],
      days: (map['days'] as List).map((e) => e as int).toList(),
      tags: (map['tags'] as List).map((e) => e.toString()).toList(),
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
        'category_id': categoryId,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'sale_start': saleStart?.toIso8601String(),
        'sale_end': saleEnd?.toIso8601String(),
        'currency': currency,
        'tags': tags,
        'days': days,
        'active': active,
        'position': position,
      };

  @override
  ProductModel copyWith({
    String? id,
    String? storeId,
    String? categoryId,
    String? storeName,
    String? storeTimezone,
    String? categoryName,
    String? name,
    String? description,
    String? imageUrl,
    num? productPrice,
    num? regularPrice,
    num? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
    String? currency,
    String? category,
    List<String>? tags,
    List<int>? days,
    bool? active,
    int? position,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      storeName: storeName ?? this.storeName,
      storeTimezone: storeTimezone ?? this.storeTimezone,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      productPrice: productPrice ?? this.productPrice,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      saleStart: saleStart ?? this.saleStart,
      saleEnd: saleEnd ?? this.saleEnd,
      currency: currency ?? this.currency,
      tags: tags ?? this.tags,
      active: active ?? this.active,
      days: days ?? this.days,
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
      'tags: $tags, '
      'active: $active, '
      'days: $days, '
      'position: $position, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
