import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/widgets/message_page.dart';

/// Widget genérico que se encarga de crear el BlocProvider y administrar los estados CRUD.
/// Recibe una función que construye el cubit y builders para cada uno de los estados.
class CrudStateHandler<T extends ModelComponent> extends StatelessWidget {
  /// Función que crea la instancia del cubit.
  final CrudCubit<T> Function(BuildContext context) createCubit;

  /// Builder para mostrar la vista en estado de carga.
  final Widget Function(BuildContext context) loadingBuilder;

  /// Builder para mostrar la vista en caso de error.
  final Widget Function(BuildContext context, CrudCubit<T> cubit, String error)
      errorBuilder;

  /// Builder para mostrar la vista en estado cargado (no editable).
  final Widget Function(
    BuildContext context,
    CrudCubit<T> cubit,
    CrudLoaded<T> state,
  ) loadedBuilder;

  /// Builder para mostrar la vista en estado de edición.
  /// Se reciben el modelo original, la copia editable, el flag de edición, el flag de envío y un posible mensaje de error.
  final Widget Function(
    BuildContext context,
    CrudCubit<T> cubit,
    CrudEditing<T> state,
  ) editingBuilder;

  /// Builder opcional para mostrar la vista en estado de creación de un nuevo elemento.
  final Widget Function(
    BuildContext context,
    CrudCubit<T> cubit,
    CrudCreate<T> state,
  ) creatingBuilder;

  /// Builder opcional para mostrar la vista en caso de eliminación.
  final Widget Function(BuildContext context, String id)? deletedBuilder;

  /// Listener opcional para realizar acciones adicionales según el estado.
  final void Function(BuildContext context, CrudState<T> state)? stateListener;

  const CrudStateHandler({
    super.key,
    required this.createCubit,
    this.loadedBuilder = defaultStateBuilder,
    this.editingBuilder = defaultStateBuilder,
    this.creatingBuilder = defaultStateBuilder,
    this.loadingBuilder = defaultLoadingBuilder,
    this.errorBuilder = defaultErrorBuilder,
    this.deletedBuilder,
    this.stateListener,
  });

  static Widget defaultStateBuilder(
    BuildContext context,
    CrudCubit cubit,
    CrudState state,
  ) =>
      MessagePage.error(
        onBack: context.pop,
        onRetry: cubit.load,
      );

  static Widget defaultLoadingBuilder(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  static Widget defaultErrorBuilder(
    BuildContext context,
    CrudCubit cubit,
    String error,
  ) {
    return MessagePage.error(
      message: error,
      onBack: context.pop,
      onRetry: cubit.load,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrudCubit<T>>(
      create: createCubit,
      child: Builder(
        builder: (context) => BlocConsumer<CrudCubit<T>, CrudState<T>>(
          listener: (context, state) {
            if (stateListener != null) {
              stateListener!(context, state);
            }
            if (state is CrudError<T>) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is CrudLoaded<T> &&
                state.message != null &&
                state.message!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
            if (state is CrudEditing<T> &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            if (state is CrudCreate<T> &&
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
              return errorBuilder(
                context,
                context.read<CrudCubit<T>>(),
                state.message,
              );
            } else if (state is CrudLoaded<T>) {
              return loadedBuilder(
                context,
                context.read<CrudCubit<T>>(),
                state,
              );
            } else if (state is CrudEditing<T>) {
              return editingBuilder(
                context,
                context.read<CrudCubit<T>>(),
                state,
              );
            } else if (state is CrudCreate<T>) {
              return creatingBuilder(
                context,
                context.read<CrudCubit<T>>(),
                state,
              );
            } else if (state is CrudDeleted<T>) {
              return deletedBuilder != null
                  ? deletedBuilder!(context, state.id)
                  : MessagePage.warning(
                      'El elemento ha sido eliminado.',
                      onBack: context.pop,
                    );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
