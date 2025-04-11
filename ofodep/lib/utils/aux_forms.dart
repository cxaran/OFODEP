import 'package:flutter/material.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';

void create(GlobalKey<FormState> formKey, CrudCubit cubit) {
  if (formKey.currentState?.validate() ?? false) {
    cubit.create();
  }
}

void submit(GlobalKey<FormState> formKey, CrudCubit cubit) {
  if (formKey.currentState?.validate() ?? false) {
    cubit.submit();
  }
}

String? validate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo es obligatorio';
  }
  return null;
}

String? validateNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo es obligatorio';
  }
  final num? numValue = num.tryParse(value);
  if (numValue == null || numValue < 0) {
    return 'El valor no es válido';
  }
  return null;
}
