import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ofodep/models/location_model.dart';
import 'package:ofodep/repositories/location_repository.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  LocationModel location;
  String? errorMessage;

  LocationLoaded({
    required this.location,
    this.errorMessage,
  });

  /// Copywith para actualizar el estado
  /// [location] nueva ubicación
  /// [errorMessage] mensaje de error
  LocationLoaded copyWith({
    LocationModel? location,
    String? errorMessage,
  }) =>
      LocationLoaded(
        location: location ?? this.location,
        errorMessage: this.errorMessage,
      );
}

class LocationError extends LocationState {
  final String error;
  LocationError({required this.error});
}

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository repository;

  LocationCubit({LocationRepository? repository})
      : repository = repository ?? LocationRepository(),
        super(LocationInitial()) {
    getCurrentLocation();
  }

  /// Obtiene la ubicación actual del usuario.
  /// Se intenta primero mediante GPS y, en caso de error, se usa el fallback por IP.
  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    try {
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

      final position = await Geolocator.getCurrentPosition();

      final location = await repository.getLocationFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (location == null) {
        throw Exception("No se pudo obtener ubicación válida");
      }

      emit(LocationLoaded(location: location));
    } catch (_) {
      try {
        final fallbackLocation = await repository.getLocationFromIP();
        emit(LocationLoaded(location: fallbackLocation));
      } catch (fallbackError) {
        emit(LocationError(error: fallbackError.toString()));
      }
    }
  }

  /// Permite actualizar la ubicación manualmente.
  /// Si no se proporciona zipCode, se intenta obtener los datos desde coordenadas.
  Future<void> updateLocationManual({
    required double latitude,
    required double longitude,
    String? zipCode,
    String? street,
    String? city,
    String? state_,
    String? country,
    String? countryCode,
    String? timezone,
  }) async {
    if (countryCode != null &&
        countryCode.isNotEmpty &&
        timezone != null &&
        timezone.isNotEmpty) {
      emit(
        LocationLoaded(
          location: LocationModel(
            latitude: latitude,
            longitude: longitude,
            zipCode: zipCode,
            street: street,
            city: city,
            state: state_,
            country: country,
            countryCode: countryCode,
            timezone: timezone,
          ),
        ),
      );
      return;
    }

    try {
      final location = await repository.getLocationFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      if (location == null) {
        _emitWithError("error_location_not_found");
      } else {
        emit(LocationLoaded(location: location));
      }
    } catch (_) {
      _emitWithError("error_location_not_found");
    }
  }

  /// Función auxiliar para emitir error preservando la ubicación actual si existe.
  void _emitWithError(String errorKey) {
    if (state is LocationLoaded) {
      final current = state as LocationLoaded;
      emit(LocationLoaded(
        location: current.location,
        errorMessage: errorKey,
      ));
    } else {
      emit(LocationError(error: errorKey));
    }
  }
}
