import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/usuario.dart';
import 'package:ofodep/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estados de la sesión
abstract class SessionState {
  final bool admin;
  const SessionState({required this.admin});
}

class SessionInitial extends SessionState {
  const SessionInitial() : super(admin: false);
}

class SessionAuthenticated extends SessionState {
  final Usuario usuario;
  SessionAuthenticated(this.usuario) : super(admin: usuario.admin);
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated() : super(admin: false);
}

/// Cubit que gestiona el estado de autenticación
class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepository = AuthRepository();
  late final StreamSubscription authSubscription;

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

  Future<void> checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final usuario = await authRepository.getUserByAuthId(session.user.id);
      if (usuario != null) {
        emit(SessionAuthenticated(usuario));
        return;
      }
      await Supabase.instance.client.auth.signOut();
      return;
    }
    emit(SessionUnauthenticated());
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }
}
