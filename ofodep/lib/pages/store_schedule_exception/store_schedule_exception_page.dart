import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_schedule_exception_cubit.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';

import 'package:ofodep/pages/error_page.dart';

class StoreScheduleExceptionPage extends StatelessWidget {
  final String? scheduleId;
  const StoreScheduleExceptionPage({
    super.key,
    this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduleId == null) return const ErrorPage();

    return BlocProvider<StoreScheduleExceptionCubit>(
      create: (context) => StoreScheduleExceptionCubit(id: scheduleId!)..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('schedule'),
              actions: [
                BlocBuilder<StoreScheduleExceptionCubit,
                    CrudState<StoreScheduleExceptionModel>>(
                  builder: (context, state) {
                    if (state is CrudLoaded<StoreScheduleExceptionModel>) {
                      return IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => context
                            .read<StoreScheduleExceptionCubit>()
                            .startEditing(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            body: BlocConsumer<StoreScheduleExceptionCubit,
                CrudState<StoreScheduleExceptionModel>>(
              listener: (context, state) {
                if (state is CrudError<StoreScheduleExceptionModel>) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is CrudEditing<StoreScheduleExceptionModel> &&
                    state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
                if (state is CrudDeleted<StoreScheduleExceptionModel>) {
                  // Por ejemplo, se puede redirigir a otra pantalla al eliminar
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                if (state is CrudInitial<StoreScheduleExceptionModel> ||
                    state is CrudLoading<StoreScheduleExceptionModel>) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CrudError<StoreScheduleExceptionModel>) {
                  return Center(child: Text(state.message));
                } else if (state is CrudLoaded<StoreScheduleExceptionModel>) {
                  // Estado no editable: muestra los datos y un botón para editar
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: ${state.model.date.toLocal().toString()}"),
                        Text("Is Closed: ${state.model.isClosed}"),
                        Text("Opening Time: ${state.model.openingTime}"),
                        Text("Closing Time: ${state.model.closingTime}"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context
                              .read<StoreScheduleExceptionCubit>()
                              .startEditing(),
                          child: const Text("Editar"),
                        ),
                      ],
                    ),
                  );
                } else if (state is CrudEditing<StoreScheduleExceptionModel>) {
                  // En modo edición, se usan TextFields que muestran los valores de editedModel.
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Date
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<StoreScheduleExceptionCubit>()
                                  .updateEditingState(
                                    (model) => model.copyWith(
                                      date: state.editedModel.date,
                                    ),
                                  ),
                          child:
                              Text(state.editedModel.date.toLocal().toString()),
                        ),

                        // Is Closed
                        Switch(
                          value: state.editedModel.isClosed,
                          onChanged: (value) => context
                              .read<StoreScheduleExceptionCubit>()
                              .updateEditingState(
                                (model) => model.copyWith(
                                  isClosed: value,
                                ),
                              ),
                          activeColor: Colors.blue,
                        ),

                        // Opening Time
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<StoreScheduleExceptionCubit>()
                                  .updateEditingState(
                                    (model) => model.copyWith(
                                      openingTime:
                                          state.editedModel.openingTime,
                                    ),
                                  ),
                          child: Text(state.editedModel.openingTime ?? '-'),
                        ),

                        // Closing Time
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<StoreScheduleExceptionCubit>()
                                  .updateEditingState(
                                    (model) => model.copyWith(
                                      closingTime:
                                          state.editedModel.closingTime,
                                    ),
                                  ),
                          child: Text(state.editedModel.closingTime ?? '-'),
                        ),

                        ElevatedButton(
                          onPressed: state.isSubmitting || !state.editMode
                              ? null
                              : () => context
                                  .read<StoreScheduleExceptionCubit>()
                                  .submit(),
                          child: state.isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text("Guardar"),
                        ),
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<StoreScheduleExceptionCubit>()
                                  .cancelEditing(),
                          child: state.isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text("Cancelar"),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          );
        },
      ),
    );
  }
}
