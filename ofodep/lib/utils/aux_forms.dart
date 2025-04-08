import 'package:flutter/material.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';

void submit(GlobalKey<FormState> formKey, CrudCubit cubit) {
  if (formKey.currentState?.validate() ?? false) {
    cubit.submit();
  }
}

String? validate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es obligatorio';
  }
  return null;
}
