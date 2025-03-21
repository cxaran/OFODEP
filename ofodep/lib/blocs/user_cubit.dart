// Estados posibles
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/usuario.dart';
import 'package:ofodep/repositories/user_repository.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserEditState extends UserState {
  final Usuario user;
  final String nombre;
  final String telefono;
  final String email;
  final bool admin;
  final bool isSubmitting;
  final String? errorMessage;

  UserEditState({
    required this.user,
    required this.nombre,
    required this.telefono,
    required this.email,
    required this.admin,
    this.isSubmitting = false,
    this.errorMessage,
  });

  // Crea el estado inicial a partir de un Usuario
  factory UserEditState.fromUser(Usuario user) {
    return UserEditState(
      user: user,
      nombre: user.nombre,
      telefono: user.telefono,
      email: user.email,
      admin: user.admin,
    );
  }

  UserEditState copyWith({
    String? nombre,
    String? telefono,
    String? email,
    bool? admin,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return UserEditState(
      user: user,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      admin: admin ?? this.admin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class UserError extends UserState {
  final String message;
  UserError({required this.message});
}

class UserCubit extends Cubit<UserState> {
  final String userId;
  final UserRepository userRepository;

  UserCubit(this.userId, {UserRepository? userRepository})
      : userRepository = userRepository ?? UserRepository(),
        super(UserInitial());

  /// Carga el usuario desde la base de datos.
  Future<void> loadUser() async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUser(userId);
      if (user != null) {
        emit(UserEditState.fromUser(user));
      } else {
        emit(UserError(message: "Usuario no encontrado"));
      }
    } catch (e) {
      emit(UserError(message: "Error al cargar usuario: $e"));
    }
  }

  /// Actualiza el campo nombre en el estado.
  void nameChanged(String name) {
    final currentState = state;
    if (currentState is UserEditState) {
      emit(currentState.copyWith(nombre: name, errorMessage: null));
    }
  }

  /// Actualiza el campo telefono en el estado.
  void phoneChanged(String phone) {
    final currentState = state;
    if (currentState is UserEditState) {
      emit(currentState.copyWith(telefono: phone, errorMessage: null));
    }
  }

  /// Actualiza el campo admin en el estado.
  void adminChanged(bool admin) {
    final currentState = state;
    if (currentState is UserEditState) {
      emit(currentState.copyWith(admin: admin, errorMessage: null));
    }
  }

  /// Envía la actualización del usuario.
  Future<void> submit() async {
    final currentState = state;
    if (currentState is UserEditState) {
      // Validación básica: el nombre no debe estar vacío o el telefono no debe estar vacío.
      // Telefono tiene que cumplis con el formato '^\+?[0-9]{7,15}$'
      if (currentState.nombre.trim().isEmpty ||
          currentState.telefono.trim().isEmpty) {
        emit(currentState.copyWith(
            errorMessage: "El nombre o el telefono es obligatorio"));
        return;
      }
      if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(currentState.telefono)) {
        emit(currentState.copyWith(errorMessage: "El telefono no es válido"));
        return;
      }
      emit(currentState.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final success = await userRepository.updateUser(
          userId,
          nombre: currentState.nombre,
          telefono: currentState.telefono,
        );
        if (success) {
          emit(currentState.copyWith(isSubmitting: false));
          // Aquí podrías agregar una navegación o notificación de éxito.
        } else {
          emit(currentState.copyWith(
              isSubmitting: false,
              errorMessage: "Error al actualizar el nombre del usuario"));
        }
      } catch (e) {
        emit(currentState.copyWith(
            isSubmitting: false, errorMessage: "Error: $e"));
      }
    }
  }
}
