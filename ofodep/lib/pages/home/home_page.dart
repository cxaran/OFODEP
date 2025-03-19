import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/session_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        String mensaje = 'Cargando...';
        if (state is SessionAuthenticated) {
          mensaje = 'Bienvenido, ${state.usuario.nombre}';
        } else if (state is SessionUnauthenticated) {
          mensaje = 'No autenticado';
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            automaticallyImplyLeading: false,
          ),
          body: Center(
              child: Column(
            children: [
              Text(mensaje),
              if (state.admin)
                ElevatedButton(
                  onPressed: () => context.push('/admin'),
                  child: const Text('Ir a Admin Dashboard'),
                ),
              ElevatedButton(
                onPressed: () => context.read<SessionCubit>().signOut(),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          )),
        );
      },
    );
  }
}
