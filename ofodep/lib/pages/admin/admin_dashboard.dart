import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/widgets/custom_list_view.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomListView(
        title: 'Admnistración general',
        children: [
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text('Usuarios'),
            onTap: () => context.push('/admin/users'),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: const Text('Comercios'),
            onTap: () => context.push('/admin/stores'),
          ),
          ListTile(
            leading: const Icon(Icons.person_pin_outlined),
            title: const Text('Administradores de comercios'),
            onTap: () => context.push('/admin/store_admins'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Productos'),
            onTap: () => context.push('/admin/products'),
          ),
        ],
      ),
    );
  }
}
