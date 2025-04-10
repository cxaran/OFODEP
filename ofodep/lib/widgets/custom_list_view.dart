import 'package:flutter/material.dart';
import 'package:ofodep/widgets/container_page.dart';
import 'package:ofodep/widgets/custom_form_validator.dart';

class CustomListView extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final String? title;
  final void Function()? onBack;
  final void Function()? onSave;
  final bool editMode;
  final bool isLoading;

  final List<Widget> actions;
  final List<Widget> children;

  const CustomListView({
    super.key,
    this.formKey,
    this.title,
    this.onBack,
    this.onSave,
    this.editMode = true,
    this.isLoading = false,
    this.actions = const [],
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> actions_ = actions.map((e) => e).toList();
    if (onSave != null) {
      actions_.add(
        ElevatedButton.icon(
          onPressed: !editMode || isLoading ? null : onSave,
          icon: const Icon(Icons.check),
          label: isLoading
              ? const CircularProgressIndicator()
              : const Text("Guardar"),
        ),
      );
    }

    Widget column = ContainerPage.zero(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: children.map((child) {
                if (child is ListTile ||
                    child is Divider ||
                    child is SwitchListTile ||
                    child is CheckboxListTile ||
                    child is CustomFormValidator) {
                  return child;
                }
                return ListTile(title: child);
              }).toList(),
            ),
          ),
          if (actions_.isNotEmpty) const Divider(height: 0),
          ...actions_.map(
            (child) {
              if (child is ListTile ||
                  child is Divider ||
                  child is SwitchListTile ||
                  child is CheckboxListTile ||
                  child is CustomFormValidator) {
                return child;
              }
              return ListTile(title: child);
            },
          ),
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
            floating: true,
            snap: true,
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
