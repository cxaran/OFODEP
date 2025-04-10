import 'package:flutter/material.dart';

class CustomFormValidator<T> extends StatelessWidget {
  final FormFieldBuilder<T> builder;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final T? initialValue;

  const CustomFormValidator({
    super.key,
    this.builder = defaultBuilder,
    this.onSaved,
    this.validator,
    this.initialValue,
  });

  static Widget defaultBuilder(FormFieldState state) {
    if (state.hasError && state.errorText != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          state.errorText!,
          style: Theme.of(state.context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(state.context).colorScheme.error),
        ),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: builder,
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,
    );
  }
}
