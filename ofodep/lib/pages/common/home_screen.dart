import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Supabase.instance.client.auth.signOut();
            },
            child: const Text('Cerrrar Sesion'),
          ),
          // Completa si el usuario es de tipo admin
          // analiza cual es el metodo mas adecuado para gestionar usuarios admin en supabase
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin/dashboard');
            },
            child: const Text('Administrar'),
          ),
        ],
      ),
    );
  }
}
