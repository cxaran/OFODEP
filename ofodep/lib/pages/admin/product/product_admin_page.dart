import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/widgets/message_page.dart';

class ProductAdminPage extends StatelessWidget {
  final String? productId;

  const ProductAdminPage({super.key, this.productId});

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
