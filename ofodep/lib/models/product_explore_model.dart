import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/abstract_params.dart';

class ProductExploreParams extends ParamsComponent {
  final String countryCode;
  final double userLat;
  final double userLng;
  final double maxDistance;
  final int page;
  final String randomSeed;
  final String? searchText;
  final List<String>? filterTags;
  final double? priceMin;
  final double? priceMax;
  final int pageSize;
  final bool sortProductPrice;
  final bool sortCreated;
  final bool ascending;
  final bool filterDelivery;
  final bool filterPickup;
  final bool filterOffers;
  final bool filterFreeShipping;

  ProductExploreParams({
    required this.countryCode,
    required this.userLat,
    required this.userLng,
    required this.maxDistance,
    required this.page,
    String? randomSeed,
    this.searchText,
    this.filterTags,
    this.priceMin,
    this.priceMax,
    this.pageSize = 10,
    this.sortProductPrice = false,
    this.sortCreated = false,
    this.ascending = false,
    this.filterDelivery = false,
    this.filterPickup = false,
    this.filterOffers = false,
    this.filterFreeShipping = false,
  }) : randomSeed = randomSeed ?? newRandomSeed();

  @override
  Map<String, dynamic> toMap() {
    return {
      'country_code': countryCode,
      'user_lat': userLat,
      'user_lng': userLng,
      'max_distance': maxDistance,
      'page': page,
      'random_seed': randomSeed,
      'search_text': searchText,
      'filter_tags': filterTags,
      'price_min': priceMin,
      'price_max': priceMax,
      'page_size': pageSize,
      'sort_product_price': sortProductPrice,
      'sort_created': sortCreated,
      'ascending': ascending,
      'filter_delivery': filterDelivery,
      'filter_pickup': filterPickup,
      'filter_offers': filterOffers,
      'filter_free_shipping': filterFreeShipping,
    };
  }

  @override
  ProductExploreParams copyWith({
    String? countryCode,
    double? userLat,
    double? userLng,
    double? maxDistance,
    int? page,
    String? randomSeed,
    String? searchText,
    List<String>? filterTags,
    double? priceMin,
    double? priceMax,
    int? pageSize,
    bool? sortProductPrice,
    bool? sortCreated,
    bool? ascending,
    bool? filterDelivery,
    bool? filterPickup,
    bool? filterOffers,
    bool? filterFreeShipping,
  }) {
    return ProductExploreParams(
      countryCode: countryCode ?? this.countryCode,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      maxDistance: maxDistance ?? this.maxDistance,
      page: page ?? this.page,
      randomSeed: randomSeed ?? this.randomSeed,
      searchText: searchText ?? this.searchText,
      filterTags: filterTags ?? this.filterTags,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      pageSize: pageSize ?? this.pageSize,
      sortProductPrice: sortProductPrice ?? this.sortProductPrice,
      sortCreated: sortCreated ?? this.sortCreated,
      ascending: ascending ?? this.ascending,
      filterDelivery: filterDelivery ?? this.filterDelivery,
      filterPickup: filterPickup ?? this.filterPickup,
      filterOffers: filterOffers ?? this.filterOffers,
      filterFreeShipping: filterFreeShipping ?? this.filterFreeShipping,
    );
  }
}

// RETURNS TABLE(
//    product_id uuid,
//    product_name text,
//    product_description text,
//    product_image_url text,
//    product_regular_price numeric,
//    product_sale_price numeric,
//    product_sale_start date,
//    product_sale_end date,
//    product_currency text,
//    product_tags text[],
//    product_days int[],
//    store_id uuid,
//    store_name text,
//    store_logo_url text,
//    store_lat numeric,
//    store_lng numeric,
//    store_pickup boolean,
//    store_delivery boolean,
//    store_delivery_price numeric,
//    store_is_open boolean,
//    product_available boolean,
//    product_price numeric,           -- Precio calculado por la función product_price
//    distance double precision,       -- Distancia en metros a la tienda
//    delivery_area boolean            -- TRUE si la posición del usuario está dentro del área de delivery de la tienda
// )

class ProductExploreModel extends ModelComponent {
  final String productName;
  final String productDescription;
  final String? productImageUrl;
  final num productRegularPrice;
  final num? productSalePrice;
  final DateTime? productSaleStart;
  final DateTime? productSaleEnd;
  final String productCurrency;
  final List<String> productTags;
  final List<int> productDays;
  final String storeId;
  final String storeName;
  final String? storeLogoUrl;
  final num storeLat;
  final num storeLng;
  final bool storePickup;
  final bool storeDelivery;
  final num? storeDeliveryPrice;
  final bool storeIsOpen;
  final bool productAvailable;
  final num productPrice;
  final double distance;
  final bool deliveryArea;

  ProductExploreModel({
    super.id,
    required this.productName,
    required this.productDescription,
    this.productImageUrl,
    required this.productRegularPrice,
    this.productSalePrice,
    this.productSaleStart,
    this.productSaleEnd,
    required this.productCurrency,
    this.productTags = const [],
    this.productDays = const [],
    required this.storeId,
    required this.storeName,
    this.storeLogoUrl,
    required this.storeLat,
    required this.storeLng,
    this.storePickup = false,
    this.storeDelivery = false,
    this.storeDeliveryPrice,
    this.storeIsOpen = false,
    this.productAvailable = false,
    required this.productPrice,
    required this.distance,
    required this.deliveryArea,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory ProductExploreModel.fromMap(Map<String, dynamic> map) {
    for (final key in map.keys) {
      print('$key: ${map[key]}');
    }
    return ProductExploreModel(
      id: map['product_id'] as String,
      productName: map['product_name'] as String,
      productDescription: map['product_description'] as String,
      productImageUrl: map['product_image_url'] as String?,
      productRegularPrice: map['product_regular_price'] as num,
      productSalePrice: map['product_sale_price'] as num?,
      productSaleStart: DateTime.tryParse(map['product_sale_start'] ?? ''),
      productSaleEnd: DateTime.tryParse(map['product_sale_end'] ?? ''),
      productCurrency: map['product_currency'] as String,
      productTags:
          (map['product_tags'] as List?)?.map((e) => e as String).toList() ??
              [],
      productDays:
          (map['product_days'] as List?)?.map((e) => e as int).toList() ?? [],
      storeId: map['store_id'] as String,
      storeName: map['store_name'] as String,
      storeLogoUrl: map['store_logo_url'] as String?,
      storeLat: map['store_lat'] as num,
      storeLng: map['store_lng'] as num,
      storePickup: map['store_pickup'] as bool,
      storeDelivery: map['store_delivery'] as bool,
      storeDeliveryPrice: map['store_delivery_price'] as num?,
      storeIsOpen: map['store_is_open'] as bool,
      productAvailable: map['product_available'] as bool,
      productPrice: map['product_price'] as num,
      distance: map['distance'] as double,
      deliveryArea: map['delivery_area'] as bool,
    );
  }

  @override
  Map<String, dynamic> toMap({
    bool includeId = true,
  }) =>
      {
        if (includeId) 'id': id,
        'product_name': productName,
        'product_description': productDescription,
        'product_image_url': productImageUrl,
        'product_regular_price': productRegularPrice,
        'product_sale_price': productSalePrice,
        'product_sale_start': productSaleStart?.toIso8601String(),
        'product_sale_end': productSaleEnd?.toIso8601String(),
        'product_currency': productCurrency,
        'product_tags': productTags,
        'product_days': productDays,
        'store_id': storeId,
        'store_name': storeName,
        'store_logo_url': storeLogoUrl,
        'store_lat': storeLat,
        'store_lng': storeLng,
        'store_pickup': storePickup,
        'store_delivery': storeDelivery,
        'store_delivery_price': storeDeliveryPrice,
        'store_is_open': storeIsOpen,
        'product_available': productAvailable,
        'product_price': productPrice,
        'distance': distance,
        'delivery_area': deliveryArea,
      };

  @override
  ProductExploreModel copyWith({
    String? id,
    String? productName,
    String? productDescription,
    String? productImageUrl,
    num? productRegularPrice,
    num? productSalePrice,
    DateTime? productSaleStart,
    DateTime? productSaleEnd,
    String? productCurrency,
    List<String>? productTags,
    List<int>? productDays,
    String? storeId,
    String? storeName,
    String? storeLogoUrl,
    num? storeLat,
    num? storeLng,
    bool? storePickup,
    bool? storeDelivery,
    num? storeDeliveryPrice,
    bool? storeIsOpen,
    bool? productAvailable,
    num? productPrice,
    double? distance,
    bool? deliveryArea,
  }) {
    return ProductExploreModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productRegularPrice: productRegularPrice ?? this.productRegularPrice,
      productSalePrice: productSalePrice ?? this.productSalePrice,
      productSaleStart: productSaleStart ?? this.productSaleStart,
      productSaleEnd: productSaleEnd ?? this.productSaleEnd,
      productCurrency: productCurrency ?? this.productCurrency,
      productTags: productTags ?? this.productTags,
      productDays: productDays ?? this.productDays,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      storeLat: storeLat ?? this.storeLat,
      storeLng: storeLng ?? this.storeLng,
      storePickup: storePickup ?? this.storePickup,
      storeDelivery: storeDelivery ?? this.storeDelivery,
      storeDeliveryPrice: storeDeliveryPrice ?? this.storeDeliveryPrice,
      storeIsOpen: storeIsOpen ?? this.storeIsOpen,
      productAvailable: productAvailable ?? this.productAvailable,
      productPrice: productPrice ?? this.productPrice,
      distance: distance ?? this.distance,
      deliveryArea: deliveryArea ?? this.deliveryArea,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'ProductExploreModel(id: $id, '
      'productName: $productName, '
      'productDescription: $productDescription, '
      'productImageUrl: $productImageUrl, '
      'productRegularPrice: $productRegularPrice, '
      'productSalePrice: $productSalePrice, '
      'productSaleStart: $productSaleStart, '
      'productSaleEnd: $productSaleEnd, '
      'productCurrency: $productCurrency, '
      'productTags: $productTags, '
      'productDays: $productDays, '
      'storeId: $storeId, '
      'storeName: $storeName, '
      'storeLogoUrl: $storeLogoUrl, '
      'storeLat: $storeLat, '
      'storeLng: $storeLng, '
      'storePickup: $storePickup, '
      'storeDelivery: $storeDelivery, '
      'storeDeliveryPrice: $storeDeliveryPrice, '
      'storeIsOpen: $storeIsOpen, '
      'productAvailable: $productAvailable, '
      'productPrice: $productPrice, '
      'distance: $distance, '
      'deliveryArea: $deliveryArea, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
