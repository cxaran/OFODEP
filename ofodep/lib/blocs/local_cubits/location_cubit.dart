import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final String zipCode;
  final String? street;
  final String? city;
  final String? state;
  final String? country;

  LocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.zipCode,
    this.street,
    this.city,
    this.state,
    this.country,
  });
}

class LocationError extends LocationState {
  final String error;
  LocationError({required this.error});
}

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial()) {
    getCurrentLocation();
  }

  /// Obtiene la ubicación actual del usuario.
  /// Se intenta primero mediante GPS y, en caso de error, se usa el fallback por IP.
  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    try {
      // Verificar servicio y permisos de ubicación
      if (!(await Geolocator.isLocationServiceEnabled())) {
        throw Exception("El servicio de ubicación está deshabilitado");
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception("Permiso de ubicación denegado");
        }
      }

      // Obtener posición con alta precisión
      final position = await Geolocator.getCurrentPosition();
      final locationLoaded = await getLocationFromCoordinates(
          position.latitude, position.longitude);

      // Si no se obtuvo el código postal, se lanza un error para probar el fallback
      if (locationLoaded == null || locationLoaded.zipCode.isEmpty) {
        throw Exception("No se obtuvo el código postal desde GPS");
      }
      emit(locationLoaded);
    } catch (error) {
      // Fallback: obtener ubicación por IP
      try {
        final locationLoaded = await getLocationFromIP();
        if (locationLoaded == null || locationLoaded.zipCode.isEmpty) {
          throw Exception(
            "No se obtuvo el código postal desde la ubicación por IP",
          );
        }
        emit(locationLoaded);
      } catch (fallbackError) {
        emit(LocationError(error: fallbackError.toString()));
      }
    }
  }

  /// Permite actualizar la ubicación manualmente.
  void updateLocationManual({
    required double latitude,
    required double longitude,
    required String zipCode,
    String? street,
    String? city,
    String? state,
    String? country,
  }) {
    emit(LocationLoaded(
      latitude: latitude,
      longitude: longitude,
      zipCode: zipCode,
      street: street,
      city: city,
      state: state,
      country: country,
    ));
  }

  /// Convierte coordenadas en datos de dirección.
  /// Primero se usa el plugin de geocoding; si no se obtiene el zip code, se recurre a OpenCage.
  Future<LocationLoaded?> getLocationFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final zipCode = placemark.postalCode ?? "";
        if (zipCode.isNotEmpty) {
          return LocationLoaded(
            latitude: latitude,
            longitude: longitude,
            zipCode: zipCode,
            street: placemark.street ?? "",
            city: placemark.locality ?? "",
            state: placemark.administrativeArea ?? "",
            country: placemark.country ?? "",
          );
        }
      }
      // Si no se obtuvo el zip code con geocoding, se recurre a OpenCage.
      return await getLocationFromCoordinatesApi(latitude, longitude);
    } catch (error) {
      return await getLocationFromCoordinatesApi(latitude, longitude);
    }
  }

  /// Fallback: obtiene la dirección usando la API de OpenCage.
  Future<LocationLoaded?> getLocationFromCoordinatesApi(
      double latitude, double longitude) async {
    try {
      const apiKey = 'a1648d98475b42f7814f50b20940d6ee';
      final url = Uri.parse(
          'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final components = data['results'][0]['components'];

          if (components['postcode'] == null) {
            return null;
          }

          return LocationLoaded(
            latitude: latitude,
            longitude: longitude,
            zipCode: components['postcode'],
            street: components['road'],
            city: components['city'] ??
                components['town'] ??
                components['village'] ??
                components['county'],
            state: components['state'],
            country: components['country'],
          );
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Obtiene la ubicación a partir de la IP usando el servicio ip-api.com.
  Future<LocationLoaded?> getLocationFromIP() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['zip'] == null) {
          throw Exception("No se obtuvieron los datos de ubicación");
        }
        return LocationLoaded(
          latitude: data['lat']?.toDouble() ?? 0.0,
          longitude: data['lon']?.toDouble() ?? 0.0,
          zipCode: data['zip'],
          street: data['street'] ?? data['road'],
          city: data['city'] ?? data['county'],
          state: data['regionName'] ?? data['state'],
          country: data['country'],
        );
      }
    } catch (e) {
      throw Exception("No se obtuvieron los datos de ubicación");
    }
    return null;
  }
}
