// Estados posibles
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/usuario.dart';
import 'package:ofodep/repositories/user_repository.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Usuario user;
  UserLoaded({required this.user});
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

  // Cargar datos del usuario
  Future<void> loadUser(String userId) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUser(userId);
      if (user != null) {
        emit(UserLoaded(user: user));
      } else {
        emit(UserError(message: 'Usuario no encontrado'));
      }
    } catch (e) {
      emit(UserError(message: 'Error al cargar usuario: $e'));
    }
  }

  // Actualizar el nombre del usuario
  Future<void> updateUserName(String newName) async {
    emit(UserLoading());
    try {
      final success = await userRepository.updateUserName(userId, newName);
      if (success) {
        final updatedUser = await userRepository.getUser(userId);
        if (updatedUser != null) {
          emit(UserLoaded(user: updatedUser));
        } else {
          emit(UserError(message: 'Error al refrescar datos del usuario'));
        }
      } else {
        emit(UserError(message: 'Error al actualizar nombre'));
      }
    } catch (e) {
      emit(UserError(message: 'Error al actualizar nombre: $e'));
    }
  }

  // Actualizar el teléfono del usuario
  Future<void> updateUserPhone(String newPhone) async {
    // Validación del formato del teléfono.
    final RegExp phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegExp.hasMatch(newPhone)) {
      emit(UserError(message: 'El número de teléfono no es válido'));
      return;
    }

    emit(UserLoading());
    try {
      final success = await userRepository.updateUserPhone(userId, newPhone);
      if (success) {
        await loadUser(userId); // Se refrescan los datos del usuario.
      } else {
        emit(UserError(message: 'Error al actualizar teléfono'));
      }
    } catch (e) {
      emit(UserError(message: 'Error al actualizar teléfono: $e'));
    }
  }

  // Refrescar datos del usuario para confirmar que son actuales
  Future<void> refreshUser() async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUser(userId);
      if (user != null) {
        emit(UserLoaded(user: user));
      } else {
        emit(UserError(message: 'Usuario no encontrado'));
      }
    } catch (e) {
      emit(UserError(message: 'Error al refrescar usuario: $e'));
    }
  }

  // Obtener los pedidos del usuario
  Future<void> getUserOrders() async {}
}
