import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "¡Ups! Algo salió mal",
        style: TextStyle(color: Colors.red, fontSize: 18),
      ),
    );
  }
}
