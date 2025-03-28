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

  // Geographical coordinates
  num? lat;
  num? lng;

  // List of store zipcodes
  String? countryCode;
  List<String>? zipcodes;

  // Delivery parameters
  bool pickup;
  bool delivery;
  num? deliveryPrice;
  num? deliveryMinimumOrder;

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
    this.lat,
    this.lng,
    this.countryCode,
    this.zipcodes,
    this.whatsapp,
    this.deliveryMinimumOrder,
    this.pickup = false,
    this.delivery = false,
    this.deliveryPrice,
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
      lat: map['lat'],
      lng: map['lng'],
      countryCode: map['country_code'] as String?,
      zipcodes: (map['zipcodes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      whatsapp: map['whatsapp'] as String?,
      deliveryMinimumOrder: map['delivery_minimum_order'],
      pickup: map['pickup'] as bool? ?? false,
      delivery: map['delivery'] as bool? ?? false,
      deliveryPrice: map['delivery_price'],
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
        'lat': lat,
        'lng': lng,
        'country_code': countryCode,
        'zipcodes': zipcodes,
        'whatsapp': whatsapp,
        'delivery_minimum_order': deliveryMinimumOrder,
        'pickup': pickup,
        'delivery': delivery,
        'delivery_price': deliveryPrice,
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
    num? lat,
    num? lng,
    String? countryCode,
    List<String>? zipcodes,
    String? whatsapp,
    num? deliveryMinimumOrder,
    bool? pickup,
    bool? delivery,
    num? deliveryPrice,
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
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      countryCode: countryCode ?? this.countryCode,
      zipcodes: zipcodes ?? this.zipcodes,
      whatsapp: whatsapp ?? this.whatsapp,
      deliveryMinimumOrder: deliveryMinimumOrder ?? this.deliveryMinimumOrder,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
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
      'lat: $lat, '
      'lng: $lng, '
      'countryCode: $countryCode, '
      'zipcodes: $zipcodes, '
      'whatsapp: $whatsapp, '
      'deliveryMinimumOrder: $deliveryMinimumOrder, '
      'pickup: $pickup, '
      'delivery: $delivery, '
      'deliveryPrice: $deliveryPrice, '
      'imgurClientId: $imgurClientId, '
      'imgurClientSecret: $imgurClientSecret, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
