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

  // Store distance
  num? distance;

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
    this.storeLogoUrl,
    this.pickup,
    this.delivery,
    this.deliveryMinimumOrder,
    this.deliveryPrice,
    this.geom,
    this.lat,
    this.lng,
    this.isOpen,
    this.distance,
    required this.name,
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
    print(map);
    return ProductStoreModel(
      id: map['id'] as String,

      // Store info
      storeId: map['store_id'] as String,
      storeName: map['store_name'],
      storeLogoUrl: map['store_logo_url'] as String?,

      // Store delivery
      pickup: map['pickup'] as bool?,
      delivery: map['delivery'] as bool?,
      deliveryPrice: map['delivery_price'],
      deliveryMinimumOrder: map['delivery_minimum_order'],

      // Store delivery zone geom
      geom: map['geom'] as Map<String, dynamic>?,

      // Store coordinates
      lat: map['lat'],
      lng: map['lng'],

      // Store is open
      isOpen: map['product_is_open'] as bool?,

      // Store distance
      distance: map['distance'],

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
      'pickup': pickup,
      'delivery': delivery,
      'delivery_minimum_order': deliveryMinimumOrder,
      'delivery_price': deliveryPrice,
      'geom': geom,
      'lat': lat,
      'lng': lng,
      'is_open': isOpen,
      'distance': distance,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'category': category,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  ProductStoreModel copyWith({
    String? storeId,
    String? storeName,
    String? storeLogoUrl,
    bool? pickup,
    bool? delivery,
    num? deliveryMinimumOrder,
    num? deliveryPrice,
    Map<String, dynamic>? geom,
    num? lat,
    num? lng,
    bool? isOpen,
    num? distance,
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
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      deliveryMinimumOrder: deliveryMinimumOrder ?? this.deliveryMinimumOrder,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      geom: geom ?? this.geom,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isOpen: isOpen ?? this.isOpen,
      distance: distance ?? this.distance,
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
        'pickup: $pickup, '
        'deliveryMinimumOrder: $deliveryMinimumOrder, '
        'deliveryPrice: $deliveryPrice, '
        'delivery: $delivery, '
        'isOpen: $isOpen, '
        'distance: $distance, '
        'name: $name, '
        'description: $description, '
        'imageUrl: $imageUrl, '
        'lat: $lat, '
        'lng: $lng, '
        'price: $price, '
        'category: $category, '
        'tags: $tags'
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
