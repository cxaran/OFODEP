import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/pages/home/drawer_home.dart';
import 'package:ofodep/pages/home/explore/explore_page.dart';
import 'package:ofodep/pages/home/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ExplorePage(),
    Center(child: Text("FavoritesPage")),
    Center(child: Text("SearchPage")),
    Center(child: Text("NotificationsPage")),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(
        _selectedIndex,
      ),
      drawer: DrawerHome(),
      bottomNavigationBar: BlocConsumer<SessionCubit, SessionState>(
        listener: (context, state) {
          if (state is SessionUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cerraste la sesión correctamente'),
              ),
            );
          }
        },
        builder: (context, state) {
          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              if (index > 1 && state is SessionUnauthenticated) {
                context.push('/login');
              }
              setState(() => _selectedIndex = index);
            },
            destinations: [
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Inicio',
                tooltip: 'Inicio',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.favorite),
                icon: Icon(Icons.favorite_border_outlined),
                label: 'Favoritos',
                tooltip: 'Favoritos',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.search_sharp),
                icon: Icon(Icons.search_outlined),
                label: 'Buscar',
                tooltip: 'Buscar',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.notifications),
                icon: Icon(Icons.notifications_outlined),
                label: 'Notificaciones',
                tooltip: 'Notificaciones',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person),
                icon: Icon(Icons.person_outlined),
                label: 'Perfil',
                tooltip: 'Perfil',
              ),
            ],
          );
        },
      ),
    );
  }
}
