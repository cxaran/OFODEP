import 'package:ofodep/models/abstract_model.dart';

class StoreModel extends ModelComponent {
  // General store information
  String name;
  String? logoUrl;

  // Contact information
  String? whatsapp;
  String? addressStreet;
  String? addressNumber;
  String? addressColony;
  String? addressZipcode;
  String? addressCity;
  String? addressState;
  String? countryCode;

  // Geographical coordinates
  num? lat;
  num? lng;

  // Zone for delivery
  Map<String, dynamic>? geom;

  // Delivery parameters
  bool pickup;
  bool delivery;
  num? deliveryPrice;
  num? deliveryMinimumOrder;

  // Is open
  bool? isOpen;

  // Imgur
  String? imgurClientId;
  String? imgurClientSecret;

  StoreModel({
    required super.id,
    required this.name,
    this.logoUrl,
    this.addressStreet,
    this.addressNumber,
    this.addressColony,
    this.addressZipcode,
    this.addressCity,
    this.addressState,
    this.countryCode,
    this.lat,
    this.lng,
    this.geom,
    this.whatsapp,
    this.deliveryMinimumOrder,
    this.pickup = false,
    this.delivery = false,
    this.deliveryPrice,
    this.isOpen,
    this.imgurClientId,
    this.imgurClientSecret,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] as String,
      name: map['name'].toString(),
      logoUrl: map['logo_url'] as String?,
      addressStreet: map['address_street'] as String?,
      addressNumber: map['address_number'] as String?,
      addressColony: map['address_colony'] as String?,
      addressZipcode: map['address_zipcode'] as String?,
      addressCity: map['address_city'] as String?,
      addressState: map['address_state'] as String?,
      countryCode: map['country_code'] as String?,
      lat: map['lat'],
      lng: map['lng'],
      geom: map['geom'] as Map<String, dynamic>?,
      whatsapp: map['whatsapp'] as String?,
      deliveryMinimumOrder: map['delivery_minimum_order'],
      pickup: map['pickup'] as bool? ?? false,
      delivery: map['delivery'] as bool? ?? false,
      deliveryPrice: map['delivery_price'],
      isOpen: map['store_is_open'] as bool?,
      imgurClientId: map['imgur_client_id'] as String?,
      imgurClientSecret: map['imgur_client_secret'] as String?,
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
        'name': name,
        'logo_url': logoUrl,
        'address_street': addressStreet,
        'address_number': addressNumber,
        'address_colony': addressColony,
        'address_zipcode': addressZipcode,
        'address_city': addressCity,
        'address_state': addressState,
        'country_code': countryCode,
        'lat': lat,
        'lng': lng,
        'geom': geom,
        'whatsapp': whatsapp,
        'delivery_minimum_order': deliveryMinimumOrder,
        'pickup': pickup,
        'delivery': delivery,
        'delivery_price': deliveryPrice,
        'store_is_open': isOpen,
        'imgur_client_id': imgurClientId,
        'imgur_client_secret': imgurClientSecret,
      };

  @override
  StoreModel copyWith({
    String? name,
    String? logoUrl,
    String? addressStreet,
    String? addressNumber,
    String? addressColony,
    String? addressZipcode,
    String? addressCity,
    String? addressState,
    String? countryCode,
    num? lat,
    num? lng,
    Map<String, dynamic>? geom,
    String? whatsapp,
    num? deliveryMinimumOrder,
    bool? pickup,
    bool? delivery,
    num? deliveryPrice,
    bool? isOpen,
    String? imgurClientId,
    String? imgurClientSecret,
  }) {
    return StoreModel(
      id: id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressColony: addressColony ?? this.addressColony,
      addressZipcode: addressZipcode ?? this.addressZipcode,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      countryCode: countryCode ?? this.countryCode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      geom: geom ?? this.geom,
      whatsapp: whatsapp ?? this.whatsapp,
      deliveryMinimumOrder: deliveryMinimumOrder ?? this.deliveryMinimumOrder,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      isOpen: isOpen ?? this.isOpen,
      imgurClientId: imgurClientId ?? this.imgurClientId,
      imgurClientSecret: imgurClientSecret ?? this.imgurClientSecret,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'StoreModel('
      'id: $id, '
      'name: $name, '
      'logoUrl: $logoUrl, '
      'addressStreet: $addressStreet, '
      'addressNumber: $addressNumber, '
      'addressColony: $addressColony, '
      'addressZipcode: $addressZipcode, '
      'addressCity: $addressCity, '
      'addressState: $addressState, '
      'countryCode: $countryCode, '
      'lat: $lat, '
      'lng: $lng, '
      'geom: $geom, '
      'whatsapp: $whatsapp, '
      'deliveryMinimumOrder: $deliveryMinimumOrder, '
      'pickup: $pickup, '
      'delivery: $delivery, '
      'deliveryPrice: $deliveryPrice, '
      'imgurClientId: $imgurClientId, '
      'imgurClientSecret: $imgurClientSecret, '
      'isOpen: $isOpen, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
