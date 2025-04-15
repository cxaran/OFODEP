import 'package:flutter/material.dart';

class CustomFormValidator<T> extends StatelessWidget {
  final FormFieldBuilder<T>? builder;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final double padding;
  final T? initialValue;

  const CustomFormValidator({
    super.key,
    this.builder,
    this.onSaved,
    this.validator,
    this.padding = 16.0,
    this.initialValue,
  });

  Widget defaultBuilder(FormFieldState state) {
    if (state.hasError && state.errorText != null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
        ),
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
      builder: builder ?? defaultBuilder,
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,
    );
  }
}
