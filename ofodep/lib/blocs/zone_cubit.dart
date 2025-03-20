import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/zona.dart';
import 'package:ofodep/repositories/zone_repository.dart';

abstract class ZoneState {}

class ZoneInitial extends ZoneState {}

class ZoneLoading extends ZoneState {}

class ZoneEditState extends ZoneState {
  final String nombre;
  final String descripcion;
  final Map<String, dynamic>? geom;
  final bool isSubmitting;
  final String? errorMessage;

  ZoneEditState({
    required this.nombre,
    required this.descripcion,
    this.geom,
    this.isSubmitting = false,
    this.errorMessage,
  });

  // Crea el estado inicial a partir de una Zona
  factory ZoneEditState.fromZona(Zona zone) {
    return ZoneEditState(
      nombre: zone.nombre,
      descripcion: zone.descripcion ?? '',
      geom: zone.geom,
    );
  }

  ZoneEditState copyWith({
    String? nombre,
    String? descripcion,
    Map<String, dynamic>? geom,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ZoneEditState(
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      geom: geom ?? this.geom,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class ZoneError extends ZoneState {
  final String message;
  ZoneError({required this.message});
}

class ZoneCubit extends Cubit<ZoneState> {
  final String zoneId;
  final ZoneRepository zoneRepository;

  ZoneCubit(this.zoneId, {ZoneRepository? zoneRepository})
      : zoneRepository = zoneRepository ?? ZoneRepository(),
        super(ZoneInitial());

  /// Carga la zona desde la base de datos.
  Future<void> loadZone() async {
    emit(ZoneLoading());
    try {
      final zone = await zoneRepository.getZone(zoneId);
      if (zone != null) {
        emit(ZoneEditState.fromZona(zone));
      } else {
        emit(ZoneError(message: "Zona no encontrada"));
      }
    } catch (e) {
      emit(ZoneError(message: "Error al cargar zona: $e"));
    }
  }

  /// Actualiza el campo nombre en el estado.
  void nameChanged(String name) {
    final currentState = state;
    if (currentState is ZoneEditState) {
      emit(currentState.copyWith(nombre: name, errorMessage: null));
    }
  }

  /// Actualiza el campo descripción en el estado.
  void descriptionChanged(String description) {
    final currentState = state;
    if (currentState is ZoneEditState) {
      emit(currentState.copyWith(descripcion: description, errorMessage: null));
    }
  }

  /// Envía la actualización de la zona.
  Future<void> submit() async {
    final currentState = state;
    if (currentState is ZoneEditState) {
      // Validación básica: el nombre no debe estar vacío.
      if (currentState.nombre.trim().isEmpty) {
        emit(currentState.copyWith(errorMessage: "El nombre es obligatorio"));
        return;
      }
      emit(currentState.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final success = await zoneRepository.updateZone(
          zoneId,
          nombre: currentState.nombre,
          descripcion: currentState.descripcion,
        );
        if (success) {
          emit(currentState.copyWith(isSubmitting: false));
          // Aquí podrías agregar una navegación o notificación de éxito.
        } else {
          emit(currentState.copyWith(
              isSubmitting: false,
              errorMessage: "Error al actualizar la zona"));
        }
      } catch (e) {
        emit(currentState.copyWith(
            isSubmitting: false, errorMessage: "Error: $e"));
      }
    }
  }
}
