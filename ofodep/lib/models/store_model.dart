class StoreModel {
  final String id;

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
  List<String>? zipcodes;

  // Delivery parameters
  bool pickup;
  bool delivery;
  num? deliveryPrice;
  num? deliveryMinimumOrder;

  // Imgur
  String? imgurClientId;
  String? imgurClientSecret;

  // Creation and update information
  DateTime createdAt;
  DateTime updatedAt;

  StoreModel({
    required this.id,
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
    this.zipcodes,
    this.whatsapp,
    this.deliveryMinimumOrder,
    this.pickup = false,
    this.delivery = false,
    this.deliveryPrice,
    this.imgurClientId,
    this.imgurClientSecret,
    required this.createdAt,
    required this.updatedAt,
  });

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
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
