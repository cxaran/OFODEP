import 'package:flutter/material.dart';

class CommercePage extends StatelessWidget {
  final String? comercioId;

  const CommercePage({super.key, required this.comercioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comercio'),
      ),
    );
  }
}
