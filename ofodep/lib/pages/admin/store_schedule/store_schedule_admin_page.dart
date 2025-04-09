import 'package:flutter/material.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_schedule_cubit.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';

class StoreScheduleAdminPage extends StatelessWidget {
  final String? scheduleId;
  StoreScheduleAdminPage({
    super.key,
    this.scheduleId,
  });

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (scheduleId == null) return const MessagePage.error();

    return Scaffold(
      // body: BlocProvider<StoreScheduleCubit>(
      //   create: (context) => StoreScheduleCubit(id: scheduleId!)..load(),
      //   child: Builder(
      //     builder: (context) {
      //       return BlocConsumer<StoreScheduleCubit,
      //           CrudState<StoreScheduleModel>>(
      //         listener: (context, state) {
      //           if (state is CrudError<StoreScheduleModel>) {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               SnackBar(content: Text(state.message)),
      //             );
      //           }
      //           if (state is CrudEditing<StoreScheduleModel> &&
      //               state.errorMessage != null &&
      //               state.errorMessage!.isNotEmpty) {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               SnackBar(content: Text(state.errorMessage!)),
      //             );
      //           }
      //           if (state is CrudDeleted<StoreScheduleModel>) {
      //             // Por ejemplo, se puede redirigir a otra pantalla al eliminar
      //             Navigator.of(context).pop();
      //           }
      //         },
      //         builder: (context, state) {
      //           if (state is CrudInitial<StoreScheduleModel> ||
      //               state is CrudLoading<StoreScheduleModel>) {
      //             return const Center(child: CircularProgressIndicator());
      //           } else if (state is CrudError<StoreScheduleModel>) {
      //             return Center(child: Text(state.message));
      //           } else if (state is CrudLoaded<StoreScheduleModel>) {
      //             // Estado no editable: muestra los datos y un botón para editar
      //             return Padding(
      //               padding: const EdgeInsets.all(16.0),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text("Days: ${state.model.days}"),
      //                   Text(
      //                     'Opening Time: '
      //                     '${state.model.openingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(state.model.openingTime!)}',
      //                   ),
      //                   Text(
      //                     'Closing Time: '
      //                     '${state.model.closingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(state.model.closingTime!)}',
      //                   ),
      //                   const SizedBox(height: 20),
      //                   ElevatedButton(
      //                     onPressed: () =>
      //                         context.read<StoreScheduleCubit>().startEditing(),
      //                     child: const Text("Editar"),
      //                   ),
      //                 ],
      //               ),
      //             );
      //           } else if (state is CrudEditing<StoreScheduleModel>) {
      //             // En modo edición, se usan TextFields que muestran los valores de editedModel.
      //             return ListView(
      //               children: [
      //                 // Days
      //                 for (var day in [1, 2, 3, 4, 5, 6, 7])
      //                   CheckboxListTile(
      //                     title: Builder(builder: (context) {
      //                       String name = '';
      //                       switch (day) {
      //                         case DateTime.monday:
      //                           name = 'monday';
      //                           break;
      //                         case DateTime.tuesday:
      //                           name = 'tuesday';
      //                           break;
      //                         case DateTime.wednesday:
      //                           name = 'wednesday';
      //                           break;
      //                         case DateTime.thursday:
      //                           name = 'thursday';
      //                           break;
      //                         case DateTime.friday:
      //                           name = 'friday';
      //                           break;
      //                         case DateTime.saturday:
      //                           name = 'saturday';
      //                           break;
      //                         case DateTime.sunday:
      //                           name = 'sunday';
      //                           break;
      //                         default:
      //                       }
      //                       return Text(name);
      //                     }),
      //                     value: state.editedModel.days.contains(day),
      //                     onChanged: (bool? checked) => context
      //                         .read<StoreScheduleCubit>()
      //                         .updateEditingState(
      //                           (model) => model.copyWith(
      //                             days: state.editedModel.days.contains(day)
      //                                 ? (List.from(model.days)..remove(day))
      //                                 : (List.from(model.days)..add(day)),
      //                           ),
      //                         ),
      //                   ),

      //                 // Botón para seleccionar la hora de apertura
      //                 ElevatedButton(
      //                   onPressed: state.isSubmitting
      //                       ? null
      //                       : () async {
      //                           StoreScheduleCubit cubit =
      //                               context.read<StoreScheduleCubit>();
      //                           final selectedTime = await showTimePicker(
      //                             context: context,
      //                             initialTime: state.editedModel.openingTime ??
      //                                 TimeOfDay.now(),
      //                           );
      //                           if (selectedTime != null) {
      //                             cubit.updateEditingState(
      //                               (model) => model.copyWith(
      //                                 openingTime: selectedTime,
      //                               ),
      //                             );
      //                           }
      //                         },
      //                   child: Text(
      //                     state.editedModel.openingTime != null
      //                         ? MaterialLocalizations.of(context)
      //                             .formatTimeOfDay(
      //                                 state.editedModel.openingTime!)
      //                         : "Seleccionar hora de apertura",
      //                   ),
      //                 ),

      //                 // Botón para seleccionar la hora de cierre
      //                 ElevatedButton(
      //                   onPressed: state.isSubmitting
      //                       ? null
      //                       : () async {
      //                           StoreScheduleCubit cubit =
      //                               context.read<StoreScheduleCubit>();
      //                           final selectedTime = await showTimePicker(
      //                             context: context,
      //                             initialTime: state.editedModel.closingTime ??
      //                                 TimeOfDay.now(),
      //                           );
      //                           if (selectedTime != null) {
      //                             cubit.updateEditingState(
      //                               (model) => model.copyWith(
      //                                 closingTime: selectedTime,
      //                               ),
      //                             );
      //                           }
      //                         },
      //                   child: Text(
      //                     state.editedModel.closingTime != null
      //                         ? MaterialLocalizations.of(context)
      //                             .formatTimeOfDay(
      //                                 state.editedModel.closingTime!)
      //                         : "Seleccionar hora de cierre",
      //                   ),
      //                 ),

      //                 ElevatedButton(
      //                   onPressed: state.isSubmitting || !state.editMode
      //                       ? null
      //                       : () => context.read<StoreScheduleCubit>().submit(),
      //                   child: state.isSubmitting
      //                       ? const CircularProgressIndicator()
      //                       : const Text("Guardar"),
      //                 ),
      //                 ElevatedButton(
      //                   onPressed: state.isSubmitting
      //                       ? null
      //                       : () => context
      //                           .read<StoreScheduleCubit>()
      //                           .cancelEditing(),
      //                   child: state.isSubmitting
      //                       ? const CircularProgressIndicator()
      //                       : const Text("Cancelar"),
      //                 ),
      //               ],
      //             );
      //           }
      //           return Container();
      //         },
      //       );
      //     },
      //   ),
      // ),
      body: CrudStateHandler<StoreScheduleModel>(
        createCubit: (context) => StoreScheduleCubit(id: scheduleId!)..load(),
        loadedBuilder: loadedBuilder,
        editingBuilder: editingBuilder,
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    CrudCubit<StoreScheduleModel> cubit,
    CrudLoaded<StoreScheduleModel> state,
  ) {
    final model = state.model;
    return CustomListView(
      title: 'Horario',
      actions: [
        ElevatedButton.icon(
          onPressed: () => cubit.startEditing(),
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),
      ],
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text('Dias'),
          subtitle: Text(model.days.map(dayName).join(', ')),
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text('Horario de apertura'),
          subtitle: Text(
            model.openingTime == null
                ? 'No definido'
                : MaterialLocalizations.of(context).formatTimeOfDay(
                    model.openingTime!,
                  ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text('Horario de cierre'),
          subtitle: Text(
            model.closingTime == null
                ? 'No definido'
                : MaterialLocalizations.of(context).formatTimeOfDay(
                    model.closingTime!,
                  ),
          ),
        ),
      ],
    );
  }

  Widget editingBuilder(
    BuildContext context,
    CrudCubit<StoreScheduleModel> cubit,
    CrudEditing<StoreScheduleModel> state,
  ) {
    final edited = state.editedModel;
    return CustomListView(
      title: 'Horario',
      formKey: formKey,
      isLoading: state.isSubmitting,
      editMode: state.editMode,
      onSave: () => submit(formKey, cubit),
      onBack: cubit.cancelEditing,
      children: [
        OutlinedButton.icon(
          onPressed: () => showTimePicker(
            context: context,
            initialTime: edited.openingTime ?? TimeOfDay.now(),
          ).then((time) => cubit.updateEditingState(
                (model) => model.copyWith(openingTime: time),
              )),
          label: Text(
            'Horario de apertura: ${edited.openingTime == null ? 'No definido' : MaterialLocalizations.of(context).formatTimeOfDay(edited.openingTime!)}',
          ),
          icon: const Icon(Icons.schedule),
        ),
        OutlinedButton.icon(
          onPressed: () => showTimePicker(
            context: context,
            initialTime: edited.closingTime ?? TimeOfDay.now(),
          ).then((time) => cubit.updateEditingState(
                (model) => model.copyWith(closingTime: time),
              )),
          label: Text(
            'Horario de cierre: ${edited.closingTime == null ? 'No definido' : MaterialLocalizations.of(context).formatTimeOfDay(edited.closingTime!)}',
          ),
          icon: const Icon(Icons.schedule),
        ),
        Divider(),
        const Text('Días de la semana'),
        for (var day in [1, 2, 3, 4, 5, 6, 7])
          CheckboxListTile(
            title: Text(dayName(day) ?? ''),
            value: edited.days.contains(day),
            onChanged: (value) => cubit.updateEditingState(
              (model) => model.copyWith(
                days: edited.days.contains(day)
                    ? (List.from(model.days)..remove(day))
                    : (List.from(model.days)..add(day)),
              ),
            ),
          ),
      ],
    );
  }
}
