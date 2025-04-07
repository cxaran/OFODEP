import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/abstract_model.dart';

/// Widget genérico que se encarga de crear el BlocProvider y administrar los estados CRUD.
/// Recibe una función que construye el cubit y builders para cada uno de los estados.
class CrudStateHandler<T extends ModelComponent> extends StatelessWidget {
  /// Función que crea la instancia del cubit.
  final CrudCubit<T> Function(BuildContext context) createCubit;

  /// Builder para mostrar la vista en estado de carga.
  final Widget Function(BuildContext context) loadingBuilder;

  /// Builder para mostrar la vista en caso de error.
  final Widget Function(BuildContext context, String error) errorBuilder;

  /// Builder para mostrar la vista en estado cargado (no editable).
  final Widget Function(BuildContext context, T model) loadedBuilder;

  /// Builder para mostrar la vista en estado de edición.
  /// Se reciben el modelo original, la copia editable, el flag de edición, el flag de envío y un posible mensaje de error.
  final Widget Function(
    CrudCubit<T> cubit,
    T model,
    T editedModel,
    bool editMode,
    bool isSubmitting,
    String? errorMessage,
  ) editingBuilder;

  /// Builder opcional para mostrar la vista en caso de eliminación.
  final Widget Function(BuildContext context, String id)? deletedBuilder;

  /// Listener opcional para realizar acciones adicionales según el estado.
  final void Function(BuildContext context, CrudState<T> state)? stateListener;

  const CrudStateHandler({
    super.key,
    required this.createCubit,
    required this.loadedBuilder,
    required this.editingBuilder,
    this.loadingBuilder = _defaultLoadingBuilder,
    this.errorBuilder = _defaultErrorBuilder,
    this.deletedBuilder,
    this.stateListener,
  });

  static Widget _defaultLoadingBuilder(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  static Widget _defaultErrorBuilder(BuildContext context, String error) {
    return Center(child: Text(error));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrudCubit<T>>(
      create: createCubit,
      child: Builder(
        builder: (context) => BlocConsumer<CrudCubit<T>, CrudState<T>>(
          listener: (context, state) {
            // Listener adicional si se pasa la función
            if (stateListener != null) {
              stateListener!(context, state);
            }
            // Ejemplo: mostrar SnackBar en errores o en edición con error.
            if (state is CrudError<T>) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is CrudEditing<T> &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            if (state is CrudInitial<T> || state is CrudLoading<T>) {
              return loadingBuilder(context);
            } else if (state is CrudError<T>) {
              return errorBuilder(context, state.message);
            } else if (state is CrudLoaded<T>) {
              return loadedBuilder(context, state.model);
            } else if (state is CrudEditing<T>) {
              return editingBuilder(
                context.read<CrudCubit<T>>(),
                state.model,
                state.editedModel,
                state.editMode,
                state.isSubmitting,
                state.errorMessage,
              );
            } else if (state is CrudDeleted<T>) {
              return deletedBuilder != null
                  ? deletedBuilder!(context, state.id)
                  : Center(child: Text('El elemento ha sido eliminado.'));
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
