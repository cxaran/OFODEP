import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/abstract_model.dart';

Future<void> create(
  GlobalKey<FormState> formKey,
  CrudCubit cubit, {
  VoidCallback? callback,
}) async {
  formKey.currentState?.reset();
  await Future.delayed(const Duration(milliseconds: 300));
  if (formKey.currentState?.validate() ?? false) {
    cubit.create().then((value) => callback?.call());
  }
}

Future<void> submit(
  GlobalKey<FormState> formKey,
  CrudCubit cubit, {
  VoidCallback? callback,
}) async {
  formKey.currentState?.reset();
  await Future.delayed(const Duration(milliseconds: 300));
  if (formKey.currentState?.validate() ?? false) {
    cubit.submit().then((_) => callback?.call());
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

String? validateNumberInteger(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo es obligatorio';
  }
  final num? numValue = num.tryParse(value);
  if (numValue == null || numValue.toInt() != numValue || numValue < 0) {
    return 'El valor no es válido';
  }
  return null;
}

/// Función auxiliar para crear un nuevo modelo.
Future<T?> pageNewModel<T extends Object?, M extends ModelComponent>(
  BuildContext context,
  String location,
  M newModel,
) =>
    context.push<T?>(
      '$location/${newModel.id}',
      extra: newModel,
    );
