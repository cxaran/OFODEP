import 'package:flutter/material.dart';

class AdminOrdersPage extends StatefulWidget {
  final String? storeId;
  final String? userId;
  const AdminOrdersPage({
    super.key,
    this.storeId,
    this.userId,
  });

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
      ),
      body: Center(
        child: Text(
          'storeId: ${widget.storeId} userId: ${widget.userId}',
        ),
      ),
    );
  }
}
