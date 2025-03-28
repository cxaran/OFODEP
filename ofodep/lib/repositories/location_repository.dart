import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:ofodep/models/location_model.dart';

class LocationRepository {
  /// Obtiene la ubicación a partir de coordenadas.
  Future<LocationModel?> getLocationFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    // Primero: plugin de geocoding
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final zipCode = placemark.postalCode ?? "";
        final countryCode = placemark.isoCountryCode ?? "";
        if (zipCode.isNotEmpty && countryCode.isNotEmpty) {
          return LocationModel(
            latitude: latitude,
            longitude: longitude,
            zipCode: zipCode,
            street: placemark.street ?? "",
            city: placemark.locality ?? "",
            state: placemark.administrativeArea ?? "",
            country: placemark.country ?? "",
            countryCode: countryCode,
          );
        }
      }
    } catch (_) {}

    // Fallback: Nominatim API
    return await _getFromNominatim(lat: latitude, lon: longitude);
  }

  /// Fallback: consulta a Nominatim API usando coordenadas
  Future<LocationModel?> _getFromNominatim({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
        ),
        headers: {
          'User-Agent': 'Mozilla/5.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        final zipCode = address?['postcode'];
        final countryCode = address?['country_code'] ?? "";

        if (zipCode != null &&
            zipCode.toString().isNotEmpty &&
            countryCode.isNotEmpty) {
          return LocationModel(
            latitude: lat,
            longitude: lon,
            zipCode: zipCode,
            street: address['road'] ??
                address['pedestrian'] ??
                address['footway'] ??
                "",
            city: address['city'] ??
                address['town'] ??
                address['village'] ??
                address['county'] ??
                "",
            state: address['state'] ?? "",
            country: address['country'] ?? "",
            countryCode: countryCode,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Obtiene ubicación a partir de un código postal.
  Future<LocationModel?> getLocationFromZipCode({
    required String countryCode,
    required String zipCode,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?postalcode=$zipCode&format=json&limit=1&countrycodes=$countryCode',
        ),
        headers: {
          'User-Agent': 'Mozilla/5.0',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final item = data.first;
          final lat = double.tryParse(item['lat'] ?? '');
          final lon = double.tryParse(item['lon'] ?? '');

          if (lat != null && lon != null) {
            return await getLocationFromCoordinates(
              latitude: lat,
              longitude: lon,
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Busca una lista de ubicaciones que contengan código postal no nulo.
  Future<List<LocationModel>> searchLocations({
    required String countryCode,
    required String query,
  }) async {
    List<LocationModel> results = [];
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query'
          '&format=json&addressdetails=1&limit=10&countrycodes=$countryCode',
        ),
        headers: {
          'User-Agent': 'Mozilla/5.0',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        for (final item in data) {
          final address = item['address'];
          final zip = address?['postcode'];
          final countryCode = address?['country_code'] ?? "";

          if (zip != null &&
              zip.toString().isNotEmpty &&
              countryCode.isNotEmpty) {
            results.add(
              LocationModel(
                latitude: double.tryParse(item['lat'] ?? '') ?? 0.0,
                longitude: double.tryParse(item['lon'] ?? '') ?? 0.0,
                zipCode: zip,
                street: address['road'] ??
                    address['pedestrian'] ??
                    address['footway'],
                city: address['city'] ??
                    address['town'] ??
                    address['village'] ??
                    address['county'],
                state: address['state'],
                country: address['country'],
                countryCode: countryCode,
              ),
            );
          }
        }
      }
    } catch (_) {}

    return results;
  }

  /// Ubicación basada en IP (fallback)
  Future<LocationModel> getLocationFromIP() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['zip'] == null || data['countryCode'] == null) {
          throw Exception("No se obtuvieron los datos de ubicación");
        }

        return LocationModel(
          latitude: (data['lat'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['lon'] as num?)?.toDouble() ?? 0.0,
          zipCode: data['zip'],
          street: data['street'] ?? data['road'],
          city: data['city'] ?? data['county'],
          state: data['regionName'] ?? data['state'],
          country: data['country'],
          countryCode: data['countryCode'] ?? data['country_code'] ?? "",
        );
      }
    } catch (_) {
      throw Exception("No se obtuvieron los datos de ubicación");
    }

    throw Exception("No se obtuvieron los datos de ubicación");
  }
}
