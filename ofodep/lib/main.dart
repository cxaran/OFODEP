// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/config/supabase_config.dart';
import 'blocs/session_cubit.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(
    BlocProvider.value(
      value: SessionCubit(),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OFODEP',
      theme: ThemeData.dark(),
      routerConfig: createRouter(
        context.watch<SessionCubit>(),
      ),
    );
  }
}
