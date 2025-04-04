import 'package:ofodep/models/abstract_model.dart';

class ProductStoreModel extends ModelComponent {
  // Store Info
  final String storeId;
  final String storeName;
  String? storeLogoUrl;

  // Store delivery
  bool? pickup;
  bool? delivery;
  num? deliveryPrice;
  num? deliveryMinimumOrder;

  // Store delivery zone geom
  Map<String, dynamic>? geom;

  // Store coordinates
  num? lat;
  num? lng;

  // Store is open
  bool? isOpen;

  // Product info
  String name;
  String? description;
  String? imageUrl;
  num? price;
  String? category;
  List<String>? tags;

  ProductStoreModel({
    required super.id,
    required this.storeId,
    required this.storeName,
    required this.name,
    this.storeLogoUrl,
    this.isOpen,
    this.pickup,
    this.delivery,
    this.deliveryPrice,
    this.deliveryMinimumOrder,
    this.geom,
    this.lat,
    this.lng,
    this.description,
    this.imageUrl,
    this.price,
    this.category,
    this.tags,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductStoreModel.fromMap(Map<String, dynamic> map) {
    return ProductStoreModel(
      id: map['id'] as String,

      // Store info
      storeId: map['store_id'] as String,
      storeName: map['stores']['name'],
      storeLogoUrl: map['stores']['logo_url'] as String?,

      // Store delivery
      pickup: map['stores']['pickup'] as bool?,
      delivery: map['stores']['delivery'] as bool?,
      deliveryPrice: map['stores']['delivery_price'],
      deliveryMinimumOrder: map['stores']['delivery_minimum_order'],

      // Store delivery zone geom
      geom: map['stores']['geom'] as Map<String, dynamic>?,

      // Store coordinates
      lat: map['stores']['lat'],
      lng: map['stores']['lng'],

      // Store is open
      isOpen: map['product_is_open'] as bool?,

      // Product info
      name: map['name'].toString(),
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
  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'store_id': storeId,
      'store_name': storeName,
      'store_logo_url': storeLogoUrl,
      'is_open': isOpen,
      'pickup': pickup,
      'delivery': delivery,
      'delivery_price': deliveryPrice,
      'delivery_minimum_order': deliveryMinimumOrder,
      'geom': geom,
      'lat': lat,
      'lng': lng,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'category': category,
      'tags': tags,
    };
  }

  @override
  ProductStoreModel copyWith({
    String? storeId,
    String? storeName,
    String? storeLogoUrl,
    bool? isOpen,
    bool? pickup,
    bool? delivery,
    num? deliveryPrice,
    num? deliveryMinimumOrder,
    Map<String, dynamic>? geom,
    num? lat,
    num? lng,
    String? name,
    String? description,
    String? imageUrl,
    num? price,
    String? category,
    List<String>? tags,
  }) {
    return ProductStoreModel(
      id: id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      isOpen: isOpen ?? this.isOpen,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      deliveryMinimumOrder: deliveryMinimumOrder ?? this.deliveryMinimumOrder,
      geom: geom ?? this.geom,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductStoreModel('
        'id: $id, '
        'storeId: $storeId, '
        'storeName: $storeName, '
        'storeLogoUrl: $storeLogoUrl, '
        'isOpen: $isOpen, '
        'pickup: $pickup, '
        'delivery: $delivery, '
        'deliveryPrice: $deliveryPrice, '
        'deliveryMinimumOrder: $deliveryMinimumOrder, '
        'geom: $geom, '
        'lat: $lat, '
        'lng: $lng, '
        'name: $name, '
        'description: $description, '
        'imageUrl: $imageUrl, '
        'price: $price, '
        'category: $category, '
        'tags: $tags, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
