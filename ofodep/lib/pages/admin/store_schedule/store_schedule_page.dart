import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_schedule_cubit.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/pages/error_page.dart';

class StoreSchedulePage extends StatelessWidget {
  final String? scheduleId;
  const StoreSchedulePage({
    super.key,
    this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduleId == null) return const ErrorPage();

    return BlocProvider<StoreScheduleCubit>(
      create: (context) => StoreScheduleCubit(id: scheduleId!)..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('schedule'),
              actions: [
                BlocBuilder<StoreScheduleCubit, CrudState<StoreScheduleModel>>(
                  builder: (context, state) {
                    if (state is CrudLoaded<StoreScheduleModel>) {
                      return IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            context.read<StoreScheduleCubit>().startEditing(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            body:
                BlocConsumer<StoreScheduleCubit, CrudState<StoreScheduleModel>>(
              listener: (context, state) {
                if (state is CrudError<StoreScheduleModel>) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is CrudEditing<StoreScheduleModel> &&
                    state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
                if (state is CrudDeleted<StoreScheduleModel>) {
                  // Por ejemplo, se puede redirigir a otra pantalla al eliminar
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                if (state is CrudInitial<StoreScheduleModel> ||
                    state is CrudLoading<StoreScheduleModel>) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CrudError<StoreScheduleModel>) {
                  return Center(child: Text(state.message));
                } else if (state is CrudLoaded<StoreScheduleModel>) {
                  // Estado no editable: muestra los datos y un botón para editar
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Days: ${state.model.days}"),
                        Text("Opening Time: ${state.model.openingTime}"),
                        Text("Closing Time: ${state.model.closingTime}"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<StoreScheduleCubit>().startEditing(),
                          child: const Text("Editar"),
                        ),
                      ],
                    ),
                  );
                } else if (state is CrudEditing<StoreScheduleModel>) {
                  // En modo edición, se usan TextFields que muestran los valores de editedModel.
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Days
                        TextField(
                          key: const ValueKey('days_store_schedule'),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.editedModel.days.join(', '),
                              selection: TextSelection.collapsed(
                                offset:
                                    state.editedModel.days.join(', ').length,
                              ),
                            ),
                          ),
                          decoration: const InputDecoration(labelText: 'Days'),
                          onChanged: (value) => context
                              .read<StoreScheduleCubit>()
                              .updateEditingState(
                                (model) => model.copyWith(
                                  days: value
                                      .split(',')
                                      .map((e) => int.parse(e))
                                      .toList(),
                                ),
                              ),
                        ),

                        // Opening Time
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<StoreScheduleCubit>()
                                  .updateEditingState(
                                    (model) => model.copyWith(
                                      openingTime:
                                          state.editedModel.openingTime,
                                    ),
                                  ),
                          child: Text(state.editedModel.openingTime),
                        ),

                        // Closing Time
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<StoreScheduleCubit>()
                                  .updateEditingState(
                                    (model) => model.copyWith(
                                      closingTime:
                                          state.editedModel.closingTime,
                                    ),
                                  ),
                          child: Text(state.editedModel.closingTime),
                        ),

                        ElevatedButton(
                          onPressed: state.isSubmitting || !state.editMode
                              ? null
                              : () =>
                                  context.read<StoreScheduleCubit>().submit(),
                          child: state.isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text("Guardar"),
                        ),
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<StoreScheduleCubit>()
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
