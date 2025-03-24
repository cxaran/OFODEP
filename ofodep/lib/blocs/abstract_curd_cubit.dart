import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

/// Estados genéricos para un cubit CRUD.
abstract class CrudState<T extends ModelComponent> {}

class CrudInitial<T extends ModelComponent> extends CrudState<T> {}

class CrudLoading<T extends ModelComponent> extends CrudState<T> {}

class CrudLoaded<T extends ModelComponent> extends CrudState<T> {
  final T model;
  CrudLoaded(this.model);
}

class CrudEditing<T extends ModelComponent> extends CrudState<T> {
  final T model;
  final T editedModel;
  final bool editMode;
  final bool isSubmitting;
  final String? errorMessage;

  /// Crea un estado de edición a partir de un modelo y una copia modificada del mismo.
  /// [model] modelo original
  /// [editedModel] modelo modificado
  /// [editMode] indica si se ha modificado algún campo (habilita el botón de guardar)
  /// [isSubmitting] indica si se está enviando la actualización
  /// [errorMessage] mensaje de error en caso de fallo al actualizar
  CrudEditing({
    required this.model,
    T? editedModel,
    this.editMode = false,
    this.isSubmitting = false,
    this.errorMessage,
  }) : editedModel = editedModel ?? (model.copyWith() as T);

  CrudEditing<T> copyWith({
    T? model,
    T? editedModel,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CrudEditing<T>(
      model: model ?? this.model,
      editedModel: editedModel ?? this.editedModel,
      editMode: editMode ?? this.editMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class CrudError<T extends ModelComponent> extends CrudState<T> {
  final String message;
  CrudError(this.message);
}

class CrudDeleted<T extends ModelComponent> extends CrudState<T> {
  final String id;
  CrudDeleted(this.id);
}

/// Cubit abstracto para operaciones CRUD genéricas.
/// Se utiliza el repositorio para realizar las operaciones y se centralizan los estados.
abstract class CrudCubit<T extends ModelComponent> extends Cubit<CrudState<T>> {
  final String id;
  final Repository<T> repository;

  CrudCubit({
    required this.id,
    required this.repository,
  }) : super(CrudInitial<T>());

  /// Carga el modelo a partir de su ID.
  /// [id] ID del modelo a cargar.
  Future<void> load() async {
    emit(CrudLoading<T>());
    try {
      final model = await repository.getById(id);
      if (model != null) {
        emit(CrudLoaded<T>(model));
      } else {
        emit(CrudError<T>('error_not_found: $id'));
      }
    } catch (e) {
      emit(CrudError<T>(e.toString()));
    }
  }

  /// Inicia el modo de edición, creando un estado que contiene el modelo original y una copia editable.
  void startEditing() {
    final current = state;
    if (current is CrudLoaded<T>) {
      emit(CrudEditing<T>(model: current.model));
    }
  }

  /// Cancela la edición y regresa al modelo original cargado.
  void cancelEditing() {
    final current = state;
    if (current is CrudEditing<T>) {
      emit(CrudLoaded<T>(current.model));
    }
  }

  /// Actualiza el estado de edición modificando únicamente el modelo de edición.
  /// [updater] es una función que recibe el modelo actual en edición y retorna el modelo actualizado.
  void updateEditingState(T Function(T current) updater) {
    final current = state;
    if (current is CrudEditing<T>) {
      final updatedEditedModel = updater(current.editedModel);
      emit(
        current.copyWith(
          editedModel: updatedEditedModel,
          editMode: true,
        ),
      );
    }
  }

  /// Envía los cambios realizados en el modelo editado.
  Future<void> submit() async {
    final current = state;
    if (current is CrudEditing<T>) {
      emit(current.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final success = await repository.update(current.editedModel);
        if (success) {
          emit(CrudLoaded<T>(current.editedModel));
        } else {
          emit(current.copyWith(
              isSubmitting: false, errorMessage: 'error(submit)'));
        }
      } catch (e) {
        emit(current.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    }
  }

  /// Elimina el modelo a partir de su ID.
  Future<void> delete() async {
    emit(CrudLoading<T>());
    try {
      final success = await repository.delete(id);
      if (success) {
        emit(CrudDeleted<T>(id));
      } else {
        emit(CrudError<T>('error(delete)'));
      }
    } catch (e) {
      emit(CrudError<T>(e.toString()));
    }
  }
}
