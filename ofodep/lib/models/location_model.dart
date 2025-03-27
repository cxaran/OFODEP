/// Modelo que representa una ubicación geográfica
class LocationModel {
  final double latitude;
  final double longitude;
  final String zipCode;
  final String? street;
  final String? city;
  final String? state;
  final String? country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.zipCode,
    this.street,
    this.city,
    this.state,
    this.country,
  });
}
