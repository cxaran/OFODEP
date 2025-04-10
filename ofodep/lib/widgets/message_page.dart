import 'package:flutter/material.dart';
import 'package:ofodep/utils/constants.dart';

class MessagePage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;
  final void Function()? onBack;
  final void Function()? onRetry;

  const MessagePage({
    super.key,
    required this.message,
    required this.icon,
    this.color,
    this.onBack,
    this.onRetry,
  });

  const MessagePage.success(
    this.message, {
    super.key,
    this.icon = Icons.check_circle,
    this.color = Colors.green,
    this.onBack,
    this.onRetry,
  });

  const MessagePage.warning(
    this.message, {
    super.key,
    this.icon = Icons.warning_rounded,
    this.color = Colors.yellow,
    this.onBack,
    this.onRetry,
  });

  const MessagePage.error({
    super.key,
    this.message = "¡Ups! Algo salió mal",
    this.icon = Icons.error,
    this.color = Colors.red,
    this.onBack,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 300,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: color,
                ),
                gap,
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                gap,
                if (onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                if (onRetry != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRetry,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
