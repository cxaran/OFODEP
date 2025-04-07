import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_schedule_cubit.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/pages/error_page.dart';

class StoreScheduleAdminPage extends StatelessWidget {
  final String? scheduleId;
  const StoreScheduleAdminPage({
    super.key,
    this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduleId == null) return const ErrorPage();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: BlocProvider<StoreScheduleCubit>(
        create: (context) => StoreScheduleCubit(id: scheduleId!)..load(),
        child: Builder(
          builder: (context) {
            return BlocConsumer<StoreScheduleCubit,
                CrudState<StoreScheduleModel>>(
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
                        Text(
                          'Opening Time: '
                          '${state.model.openingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(state.model.openingTime!)}',
                        ),
                        Text(
                          'Closing Time: '
                          '${state.model.closingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(state.model.closingTime!)}',
                        ),
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
                  return ListView(
                    children: [
                      // Days
                      for (var day in [1, 2, 3, 4, 5, 6, 7])
                        CheckboxListTile(
                          title: Builder(builder: (context) {
                            String name = '';
                            switch (day) {
                              case DateTime.monday:
                                name = 'monday';
                                break;
                              case DateTime.tuesday:
                                name = 'tuesday';
                                break;
                              case DateTime.wednesday:
                                name = 'wednesday';
                                break;
                              case DateTime.thursday:
                                name = 'thursday';
                                break;
                              case DateTime.friday:
                                name = 'friday';
                                break;
                              case DateTime.saturday:
                                name = 'saturday';
                                break;
                              case DateTime.sunday:
                                name = 'sunday';
                                break;
                              default:
                            }
                            return Text(name);
                          }),
                          value: state.editedModel.days.contains(day),
                          onChanged: (bool? checked) => context
                              .read<StoreScheduleCubit>()
                              .updateEditingState(
                                (model) => model.copyWith(
                                  days: state.editedModel.days.contains(day)
                                      ? (List.from(model.days)..remove(day))
                                      : (List.from(model.days)..add(day)),
                                ),
                              ),
                        ),

                      // Botón para seleccionar la hora de apertura
                      ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () async {
                                StoreScheduleCubit cubit =
                                    context.read<StoreScheduleCubit>();
                                final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: state.editedModel.openingTime ??
                                      TimeOfDay.now(),
                                );
                                if (selectedTime != null) {
                                  cubit.updateEditingState(
                                    (model) => model.copyWith(
                                      openingTime: selectedTime,
                                    ),
                                  );
                                }
                              },
                        child: Text(
                          state.editedModel.openingTime != null
                              ? MaterialLocalizations.of(context)
                                  .formatTimeOfDay(
                                      state.editedModel.openingTime!)
                              : "Seleccionar hora de apertura",
                        ),
                      ),

                      // Botón para seleccionar la hora de cierre
                      ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () async {
                                StoreScheduleCubit cubit =
                                    context.read<StoreScheduleCubit>();
                                final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: state.editedModel.closingTime ??
                                      TimeOfDay.now(),
                                );
                                if (selectedTime != null) {
                                  cubit.updateEditingState(
                                    (model) => model.copyWith(
                                      closingTime: selectedTime,
                                    ),
                                  );
                                }
                              },
                        child: Text(
                          state.editedModel.closingTime != null
                              ? MaterialLocalizations.of(context)
                                  .formatTimeOfDay(
                                      state.editedModel.closingTime!)
                              : "Seleccionar hora de cierre",
                        ),
                      ),

                      ElevatedButton(
                        onPressed: state.isSubmitting || !state.editMode
                            ? null
                            : () => context.read<StoreScheduleCubit>().submit(),
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
                  );
                }
                return Container();
              },
            );
          },
        ),
      ),
    );
  }
}
