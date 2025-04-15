import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/enums.dart';

// -- 2.4 Vistas para obtener los datos del comercio
// CREATE OR REPLACE VIEW public.store_info WITH (security_invoker = on) AS
// SELECT
//     s.id,
//     s.name,
//     s.logo_url,
//     s.country_code,
//     s.timezone,
//     s.lat,
//     s.lng,
//     s.created_at,
//     ss.subscription_type,
//     ss.expiration_date
// FROM stores s
// LEFT JOIN store_subscriptions ss ON ss.store_id = s.id;
class StoreInfoModel extends ModelComponent {
  final String name;
  final String? logoUrl;
  final String countryCode;
  final String timezone;
  final num? lat;
  final num? lng;
  final SubscriptionType subscriptionType;
  final DateTime? expirationDate;

  StoreInfoModel({
    super.id,
    required this.name,
    this.logoUrl,
    required this.countryCode,
    required this.timezone,
    this.lat,
    this.lng,
    required this.subscriptionType,
    this.expirationDate,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreInfoModel.fromMap(Map<String, dynamic> map) {
    return StoreInfoModel(
      id: map['id'],
      name: map['name'],
      logoUrl: map['logo_url'],
      countryCode: map['country_code'],
      timezone: map['timezone'],
      lat: map['lat'],
      lng: map['lng'],
      subscriptionType: SubscriptionType.fromString(map['subscription_type']),
      expirationDate: DateTime.tryParse(map['expiration_date'] ?? ''),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'name': name,
        'logo_url': logoUrl,
        'country_code': countryCode,
        'timezone': timezone,
        'lat': lat,
        'lng': lng,
        'subscription_type': subscriptionType.description,
        'expiration_date': expirationDate?.toIso8601String(),
      };

  @override
  StoreInfoModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? countryCode,
    String? timezone,
    num? lat,
    num? lng,
    SubscriptionType? subscriptionType,
    DateTime? expirationDate,
  }) {
    return StoreInfoModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'StoreInfoModel('
      'id: $id, '
      'name: $name, '
      'logoUrl: $logoUrl, '
      'countryCode: $countryCode, '
      'timezone: $timezone, '
      'lat: $lat, '
      'lng: $lng, '
      'subscriptionType: $subscriptionType, '
      'expirationDate: $expirationDate'
      ')';
}
