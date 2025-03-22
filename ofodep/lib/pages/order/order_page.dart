import 'package:flutter/widgets.dart';

class OrderPage extends StatefulWidget {
  final String? orderId;
  const OrderPage({super.key, this.orderId});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
