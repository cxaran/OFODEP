// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/local_cubits/location_cubit.dart';
import 'package:ofodep/config/supabase_config.dart';
import 'blocs/local_cubits/session_cubit.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SessionCubit()),
        BlocProvider(create: (_) => LocationCubit()),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OFODEP',
      theme: ThemeData.dark(),
      routerConfig: createRouter(
        context.watch<SessionCubit>(),
      ),
    );
  }
}
