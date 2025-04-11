import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

/// Estados genéricos para un cubit CRUD.
abstract class CrudState<T extends ModelComponent> {}

class CrudInitial<T extends ModelComponent> implements CrudState<T> {}

class CrudLoading<T extends ModelComponent> implements CrudState<T> {}

class CrudLoaded<T extends ModelComponent> implements CrudState<T> {
  final T model;
  final String? message;
  CrudLoaded(this.model, {this.message});
}

class CrudCreate<T extends ModelComponent> implements CrudState<T> {
  final T editedModel;

  final bool isSubmitting;
  final String? errorMessage;

  /// Crea un estado de edición a partir de un modelo y una copia modificada del mismo.

  /// [editedModel] modelo modificado
  /// [editMode] indica si se ha modificado algún campo (habilita el botón de guardar)
  /// [isSubmitting] indica si se está enviando la actualización
  /// [errorMessage] mensaje de error en caso de fallo al actualizar
  CrudCreate({
    required this.editedModel,
    this.isSubmitting = false,
    this.errorMessage,
  });

  CrudCreate.fromModel(this.editedModel)
      : isSubmitting = false,
        errorMessage = null;

  CrudCreate<T> copyWith({
    T? editedModel,
    bool? isSubmitting,
    String? errorMessage,
  }) =>
      CrudCreate<T>(
        editedModel: editedModel ?? this.editedModel,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: errorMessage,
      );
}

class CrudEditing<T extends ModelComponent> implements CrudState<T> {
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

  CrudEditing.fromModel(this.model)
      : editedModel = model.copyWith() as T,
        editMode = false,
        isSubmitting = false,
        errorMessage = null;

  CrudEditing<T> copyWith({
    T? model,
    T? editedModel,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
  }) =>
      CrudEditing<T>(
        model: model ?? this.model,
        editedModel: editedModel ?? this.editedModel,
        editMode: editMode ?? this.editMode,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: errorMessage,
      );
}

class CrudError<T extends ModelComponent> implements CrudState<T> {
  final String? id;
  final String message;
  CrudError(this.message, {this.id});
}

class CrudDeleted<T extends ModelComponent> implements CrudState<T> {
  final String id;
  CrudDeleted(this.id);
}

/// Cubit abstracto para operaciones CRUD genéricas.
/// Se utiliza el repositorio para realizar las operaciones y se centralizan los estados.
abstract class CrudCubit<T extends ModelComponent, R extends Repository<T>>
    extends Cubit<CrudState<T>> {
  final R repository;

  CrudCubit({
    required this.repository,
    CrudState<T>? initialState,
  }) : super(initialState ?? CrudInitial<T>());

  /// Carga el modelo a partir de su ID.
  /// [id] ID del modelo a cargar.
  /// [model] modelo a cargar si existe.
  /// [createModel] modelo a crear si no existe.
  Future<void> load(
    String? id, {
    T? model,
    T? createModel,
  }) async {
    emit(CrudLoading<T>());
    if (model != null) {
      emit(CrudLoaded<T>(model));
      return;
    }
    if (createModel != null) {
      emit(CrudCreate<T>(editedModel: createModel));
      return;
    }

    if (id == null) {
      emit(CrudError<T>('id is null', id: id));
      return;
    }

    try {
      final model = await repository.getById(id);
      if (model != null) {
        emit(CrudLoaded<T>(model));
      } else {
        emit(CrudError<T>('not_found: $id', id: id));
      }
    } catch (e) {
      emit(CrudError<T>(e.toString(), id: id));
    }
  }

  void onRetry() {
    final current = state;
    if (current is CrudError<T>) {
      load(current.id);
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

  /// Actualiza el estado modificando únicamente el modelo de edición.
  /// [updater] es una función que recibe el modelo actual en edición y retorna el modelo actualizado.
  void updateEditedModel(T Function(T current) updater) {
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
    if (current is CrudCreate<T>) {
      final updatedEditedModel = updater(current.editedModel);
      emit(current.copyWith(editedModel: updatedEditedModel));
    }
  }

  /// Envía los cambios realizados en el modelo editado.
  /// [successMessage] mensaje de éxito a mostrar en caso de éxito.
  Future<void> submit({String? successMessage}) async {
    final current = state;
    if (current is CrudEditing<T>) {
      emit(current.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final success = await repository.update(current.editedModel);
        if (success) {
          emit(CrudLoaded<T>(
            current.editedModel,
            message: successMessage ?? '$T has been updated',
          ));
        } else {
          emit(current.copyWith(
              isSubmitting: false, errorMessage: 'error(submit)'));
        }
      } catch (e) {
        emit(current.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    }
    if (current is CrudCreate<T>) {
      emit(current.copyWith(errorMessage: 'error(CrudCreate)'));
    }
  }

  /// Crea el modelo.
  /// [successMessage] mensaje de éxito a mostrar en caso de éxito.
  Future<String?> create({String? successMessage}) async {
    final current = state;
    if (current is CrudCreate<T>) {
      emit(current.copyWith(isSubmitting: true, errorMessage: null));
      try {
        print(current.editedModel.toMap(includeId: false));
        final createdId = await repository.create(current.editedModel);
        if (createdId != null) {
          emit(CrudLoaded<T>(
            current.editedModel.copyWith(id: createdId) as T,
            message: successMessage ?? '$T has been created',
          ));
          return createdId;
        } else {
          emit(
            current.copyWith(
              isSubmitting: false,
              errorMessage: 'error(create)',
            ),
          );
        }
      } catch (e) {
        emit(current.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    }
    if (current is CrudEditing<T>) {
      emit(current.copyWith(errorMessage: 'error(CrudEditing)'));
    }
    return null;
  }

  /// Elimina el modelo a partir de su ID.
  Future<void> delete() async {
    final current = state;
    if (current is CrudLoaded<T>) {
      emit(CrudLoading<T>());
      try {
        final success = await repository.delete(current.model.id);
        if (success) {
          emit(CrudDeleted<T>(current.model.id));
        } else {
          emit(CrudError<T>('error(delete)'));
        }
      } catch (e) {
        emit(CrudError<T>(e.toString()));
      }
    }
  }
}
