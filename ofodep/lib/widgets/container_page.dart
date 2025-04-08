import 'package:flutter/widgets.dart';

class ContainerPage extends StatelessWidget {
  final double maxWidth;
  final double padding;
  final Widget? child;
  const ContainerPage({
    super.key,
    this.maxWidth = 600,
    this.padding = 20,
    this.child,
  });

  const ContainerPage.zero({
    super.key,
    this.maxWidth = 600,
    this.padding = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: child,
        ),
      ),
    );
  }
}
