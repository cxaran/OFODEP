/// Modelo que representa una ubicación geográfica
class LocationModel {
  final double latitude;
  final double longitude;
  final String? zipCode;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  late final String countryCode;
  final String? timezone;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.zipCode,
    this.street,
    this.city,
    this.state,
    this.country,
    required String countryCode,
    this.timezone,
  }) : countryCode = countryCode.toUpperCase();

  @override
  String toString() {
    return 'LocationModel(latitude: $latitude,'
        ' longitude: $longitude,'
        ' zipCode: $zipCode,'
        ' street: $street,'
        ' city: $city,'
        ' state: $state,'
        ' country: $country,'
        ' countryCode: $countryCode'
        ' timezone: $timezone'
        ')';
  }
}
