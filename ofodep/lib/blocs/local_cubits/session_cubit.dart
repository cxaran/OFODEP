import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estados de la sesión
/// [SessionInitial] estado inicial
/// [SessionAuthenticated] estado de autenticación
/// [SessionUnauthenticated] estado de no autenticación
abstract class SessionState {
  const SessionState();
}

class SessionInitial extends SessionState {
  const SessionInitial() : super();
}

class SessionAuthenticated extends SessionState {
  final UserModel user;

  /// Crea el estado de autenticación a partir de un Usuario
  /// [user] Usuario a copiar
  SessionAuthenticated(this.user);
}

class SessionUnauthenticated extends SessionState {
  final String? errorMessage;
  const SessionUnauthenticated({
    this.errorMessage,
  }) : super();
}

/// Cubit que gestiona el estado de autenticación
class SessionCubit extends Cubit<SessionState> {
  final UserRepository userRepository = UserRepository();
  late final StreamSubscription authSubscription;

  /// Crea un Cubit que gestiona el estado de autenticación
  SessionCubit() : super(SessionInitial()) {
    // Suscribirse a los cambios de autenticación de Supabase
    authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        checkSession();
      } else if (data.event == AuthChangeEvent.signedOut) {
        emit(SessionUnauthenticated());
      }
    });
    // Verificar la sesión al iniciar el Cubit
    checkSession();
  }

  /// Verifica la sesión actual
  Future<void> checkSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        UserModel? user = await userRepository.getById(session.user.id);
        if (user != null) {
          emit(SessionAuthenticated(user));
          return;
        }
        await Supabase.instance.client.auth.signOut();
        return;
      }
    } on Exception catch (e) {
      emit(SessionUnauthenticated(errorMessage: e.toString()));
      return;
    }
    emit(SessionUnauthenticated());
  }

  /// Elimina la sesión actual
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }
}
