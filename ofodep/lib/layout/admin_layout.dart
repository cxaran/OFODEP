import 'package:flutter/material.dart';
import 'package:ofodep/widgets/container_page.dart';

class AdminLayout extends StatelessWidget {
  final Widget? child;
  const AdminLayout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContainerPage(
        padding: 0,
        child: child,
      ),
    );
  }
}
