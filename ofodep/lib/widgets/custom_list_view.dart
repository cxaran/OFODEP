import 'package:flutter/material.dart';
import 'package:ofodep/widgets/container_page.dart';

class CustomListView extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final String? title;
  final void Function()? onBack;
  final List<Widget> actions;
  final List<Widget> children;

  const CustomListView({
    super.key,
    this.formKey,
    this.title,
    this.onBack,
    this.actions = const [],
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    Widget column = ContainerPage.zero(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: children.map((child) {
                if (child is ListTile) {
                  return child;
                }
                if (child is Divider) {
                  return child;
                }
                return ListTile(
                  title: child,
                );
              }).toList(),
            ),
          ),
          if (actions.isNotEmpty) const Divider(height: 0),
          ...actions.map((child) {
            if (child is ListTile) {
              return child;
            }
            if (child is Divider) {
              return child;
            }
            return ListTile(
              title: child,
            );
          }),
        ],
      ),
    );

    if (formKey != null) {
      column = Form(
        key: formKey,
        child: column,
      );
    }

    if (title == null && onBack == null) {
      return column;
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: Text(title ?? ''),
            leading: onBack != null
                ? IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
          ),
        ];
      },
      body: column,
    );
  }
}
