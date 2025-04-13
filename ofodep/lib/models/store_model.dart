import 'package:ofodep/models/abstract_model.dart';

class StoreModel extends ModelComponent {
  // General store information
  String name;
  String? logoUrl;

  // Contact information
  String? addressStreet;
  String? addressNumber;
  String? addressColony;
  String? addressZipcode;
  String? addressCity;
  String? addressState;
  String? countryCode;
  String? timezone;

  // Social media links
  String? whatsapp;
  bool? whatsappAllow;
  String? facebookLink;
  String? instagramLink;

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
    this.timezone,
    this.lat,
    this.lng,
    this.geom,
    this.whatsapp,
    this.whatsappAllow,
    this.facebookLink,
    this.instagramLink,
    this.deliveryMinimumOrder,
    this.pickup = false,
    this.delivery = false,
    this.deliveryPrice,
    this.isOpen,
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
      timezone: map['timezone'] as String?,
      lat: map['lat'],
      lng: map['lng'],
      geom: map['geom'] as Map<String, dynamic>?,
      whatsapp: map['whatsapp'] as String?,
      whatsappAllow: map['whatsapp_allow'] as bool?,
      facebookLink: map['facebook_link'] as String?,
      instagramLink: map['instagram_link'] as String?,
      deliveryMinimumOrder: map['delivery_minimum_order'],
      pickup: map['pickup'] as bool? ?? false,
      delivery: map['delivery'] as bool? ?? false,
      deliveryPrice: map['delivery_price'],
      isOpen: map['store_is_open'] as bool?,
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
        'timezone': timezone,
        'lat': lat,
        'lng': lng,
        'geom': geom,
        'whatsapp': whatsapp,
        'whatsapp_allow': whatsappAllow,
        'facebook_link': facebookLink,
        'instagram_link': instagramLink,
        'delivery_minimum_order': deliveryMinimumOrder,
        'pickup': pickup,
        'delivery': delivery,
        'delivery_price': deliveryPrice,
      };

  @override
  StoreModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? addressStreet,
    String? addressNumber,
    String? addressColony,
    String? addressZipcode,
    String? addressCity,
    String? addressState,
    String? countryCode,
    String? timezone,
    num? lat,
    num? lng,
    Map<String, dynamic>? geom,
    String? whatsapp,
    bool? whatsappAllow,
    String? facebookLink,
    String? instagramLink,
    num? deliveryMinimumOrder,
    bool? pickup,
    bool? delivery,
    num? deliveryPrice,
    bool? isOpen,
    String? imgurClientId,
    String? imgurClientSecret,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressColony: addressColony ?? this.addressColony,
      addressZipcode: addressZipcode ?? this.addressZipcode,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      geom: geom ?? this.geom,
      whatsapp: whatsapp ?? this.whatsapp,
      whatsappAllow: whatsappAllow ?? this.whatsappAllow,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      deliveryMinimumOrder: deliveryMinimumOrder ?? this.deliveryMinimumOrder,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      isOpen: isOpen ?? this.isOpen,
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
      'timezone: $timezone, '
      'lat: $lat, '
      'lng: $lng, '
      'geom: $geom, '
      'whatsapp: $whatsapp, '
      'whatsappAllow: $whatsappAllow, '
      'facebookLink: $facebookLink, '
      'instagramLink: $instagramLink, '
      'deliveryMinimumOrder: $deliveryMinimumOrder, '
      'pickup: $pickup, '
      'delivery: $delivery, '
      'deliveryPrice: $deliveryPrice, '
      'isOpen: $isOpen, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
