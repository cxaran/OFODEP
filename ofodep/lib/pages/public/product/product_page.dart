import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/widgets/message_page.dart';

class ProductPage extends StatelessWidget {
  final String? productId;
  const ProductPage({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    if (productId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }
    return Scaffold();
  }
}
