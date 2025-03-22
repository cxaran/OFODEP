import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';

/// Estados posibles
/// [UserInitial] estado inicial
/// [UserLoading] estado de carga
/// [UserEditState] estado de edición
/// [UserError] estado de error

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserEditState extends UserState {
  final String name; // Antes: nombre
  final String phone; // Antes: telefono
  final String email;
  final bool admin;
  final bool editMode;
  final bool isSubmitting;
  final String? errorMessage;

  /// Crea el estado de edición a partir de un Usuario
  /// [name] nuevo nombre del usuario
  /// [phone] nuevo teléfono del usuario
  /// [email] nuevo email del usuario
  /// [admin] nuevo valor de admin del usuario
  /// [editMode] indica si el usuario está en modo de edición
  /// [isSubmitting] indica si el usuario está enviando los cambios
  /// [errorMessage] mensaje de error
  UserEditState({
    required this.name,
    required this.phone,
    required this.email,
    required this.admin,
    this.editMode = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Crea el estado inicial a partir de un Usuario
  /// [user] Usuario a copiar
  factory UserEditState.fromUser(UserModel user) {
    return UserEditState(
      name: user.name,
      phone: user.phone,
      email: user.email,
      admin: user.admin,
    );
  }

  UserEditState copyWith({
    String? name,
    String? phone,
    String? email,
    bool? admin,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return UserEditState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      admin: admin ?? this.admin,
      editMode: editMode ?? this.editMode,
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

  /// Actualiza el campo 'name' en el estado.
  /// [name] nuevo nombre del usuario
  void nameChanged(String name) {
    final currentState = state;
    if (currentState is UserEditState) {
      emit(currentState.copyWith(
        name: name,
        editMode: true,
        errorMessage: null,
      ));
    }
  }

  /// Actualiza el campo 'phone' en el estado.
  /// [phone] nuevo teléfono del usuario
  void phoneChanged(String phone) {
    final currentState = state;
    if (currentState is UserEditState) {
      emit(currentState.copyWith(
        phone: phone,
        editMode: true,
        errorMessage: null,
      ));
    }
  }

  /// Actualiza el flag 'admin' en el estado.
  /// [admin] nuevo valor de admin del usuario
  void adminChanged(bool admin) {
    final currentState = state;
    if (currentState is UserEditState) {
      emit(currentState.copyWith(
        admin: admin,
        editMode: true,
        errorMessage: null,
      ));
    }
  }

  /// Envía la actualización del usuario.
  Future<void> submit() async {
    final currentState = state;
    if (currentState is UserEditState) {
      // Validación básica: el nombre (name) no debe estar vacío o el teléfono (phone) no debe estar vacío.
      if (currentState.name.trim().isEmpty ||
          currentState.phone.trim().isEmpty) {
        emit(currentState.copyWith(
            errorMessage: "El nombre o el teléfono es obligatorio"));
        return;
      }
      // Teléfono tiene que cumplir con el formato '^\+?[0-9]{7,15}$'
      if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(currentState.phone)) {
        emit(currentState.copyWith(errorMessage: "El teléfono no es válido"));
        return;
      }
      emit(currentState.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final success = await userRepository.updateUser(
          userId,
          name: currentState.name,
          phone: currentState.phone,
        );
        if (success) {
          emit(currentState.copyWith(editMode: false, isSubmitting: false));
        } else {
          emit(currentState.copyWith(
              isSubmitting: false,
              errorMessage: "Error al actualizar los datos del usuario"));
        }
      } catch (e) {
        emit(currentState.copyWith(
            isSubmitting: false, errorMessage: "Error: $e"));
      }
    }
  }
}
