import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_schedule_exception_cubit.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_form_validator.dart';
import 'package:ofodep/widgets/custom_list_view.dart';

import 'package:ofodep/widgets/message_page.dart';

class StoreScheduleExceptionAdminPage extends StatelessWidget {
  final String? scheduleId;
  final StoreScheduleExceptionModel? createModel;
  StoreScheduleExceptionAdminPage({
    super.key,
    this.scheduleId,
    this.createModel,
  });

  final formEditingKey = GlobalKey<FormState>();
  final formCreatingKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (scheduleId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: CrudStateHandler<StoreScheduleExceptionModel,
          StoreScheduleExceptionCubit>(
        createCubit: (context) => StoreScheduleExceptionCubit()
          ..load(
            scheduleId!,
            createModel: createModel,
          ),
        loadedBuilder: loadedBuilder,
        editingBuilder: (context, cubit, state) => buildForm(
          context,
          formKey: formEditingKey,
          cubit: cubit,
          edited: state.editedModel,
          editMode: state.editMode,
          isLoading: state.isSubmitting,
          onSave: () => submit(formEditingKey, cubit),
          onBack: cubit.cancelEditing,
        ),
        creatingBuilder: (context, cubit, state) => buildForm(
          context,
          formKey: formCreatingKey,
          cubit: cubit,
          edited: state.editedModel,
          isLoading: state.isSubmitting,
          onSave: () => create(formCreatingKey, cubit),
        ),
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    StoreScheduleExceptionCubit cubit,
    CrudLoaded<StoreScheduleExceptionModel> state,
  ) {
    final model = state.model;
    return CustomListView(
      title: 'Horario',
      actions: [
        ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¿Eliminar horario?'),
              content: const Text('Esta acción no se puede deshacer'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => cubit.delete().then(
                        (_) => context.mounted
                            ? Navigator.of(context).pop()
                            : null,
                      ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.delete),
          label: const Text('Eliminar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => cubit.startEditing(),
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),
      ],
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text('Fecha'),
          subtitle: Text(
            MaterialLocalizations.of(context).formatCompactDate(
              model.date,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.close_sharp),
          title: Text('Cerrado'),
          subtitle: Text(
            model.isClosed ? 'Si' : 'No',
          ),
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

  Widget buildForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required StoreScheduleExceptionCubit cubit,
    required StoreScheduleExceptionModel edited,
    required bool isLoading,
    bool editMode = true,
    required VoidCallback onSave,
    VoidCallback? onBack,
  }) {
    return CustomListView(
      title: 'Horario',
      formKey: formKey,
      isLoading: isLoading,
      editMode: editMode,
      onSave: onSave,
      onBack: onBack,
      children: [
        Text(
          'Este horario se aplicará unicamente a la fecha seleccionada. Se puede aplicar en dias festivos y días especiales',
        ),
        OutlinedButton.icon(
          onPressed: () => showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          ).then((date) => cubit.updateEditedModel(
                (model) => model.copyWith(date: date),
              )),
          label: Text(
            'Fecha: ${MaterialLocalizations.of(context).formatCompactDate(
              edited.date,
            )}',
          ),
          icon: const Icon(Icons.calendar_today),
        ),
        CustomFormValidator(
          initialValue: edited.date,
          validator: (value) => value == null ? 'Selecciona una fecha' : null,
        ),
        Divider(),
        CheckboxListTile(
          value: edited.isClosed,
          title: Text('Cerrado'),
          onChanged: (value) => cubit.updateEditedModel(
            (model) => StoreScheduleExceptionModel(
              id: model.id,
              storeId: model.storeId,
              date: model.date,
              isClosed: value ?? false,
              openingTime: (value ?? false) ? null : model.openingTime,
              closingTime: (value ?? false) ? null : model.closingTime,
            ),
          ),
        ),
        Divider(),
        OutlinedButton.icon(
          onPressed: () => showTimePicker(
            context: context,
            initialTime: edited.openingTime ?? TimeOfDay.now(),
          ).then(
            (time) => cubit.updateEditedModel(
              (model) => StoreScheduleExceptionModel(
                id: model.id,
                storeId: model.storeId,
                date: model.date,
                isClosed: time != null ? false : model.isClosed,
                openingTime: time,
                closingTime: model.closingTime,
              ),
            ),
          ),
          label: Text(
            'Horario de apertura: ${edited.openingTime == null ? 'No definido' : MaterialLocalizations.of(context).formatTimeOfDay(edited.openingTime!)}',
          ),
          icon: const Icon(Icons.schedule),
        ),
        CustomFormValidator(
          initialValue: edited.openingTime,
          validator: (value) => value == null
              ? (edited.isClosed ? null : 'Selecciona un horario de apertura')
              : (edited.isClosed
                  ? 'El horario de apertura no puede ser definido'
                  : null),
        ),
        OutlinedButton.icon(
          onPressed: () => showTimePicker(
            context: context,
            initialTime: edited.closingTime ?? TimeOfDay.now(),
          ).then(
            (time) => cubit.updateEditedModel(
              (model) => StoreScheduleExceptionModel(
                id: model.id,
                storeId: model.storeId,
                date: model.date,
                isClosed: time != null ? false : model.isClosed,
                openingTime: model.openingTime,
                closingTime: time,
              ),
            ),
          ),
          label: Text(
            'Horario de cierre: ${edited.closingTime == null ? 'No definido' : MaterialLocalizations.of(context).formatTimeOfDay(edited.closingTime!)}',
          ),
          icon: const Icon(Icons.schedule),
        ),
        CustomFormValidator(
          initialValue: edited.closingTime,
          validator: (value) {
            if (value == null) {
              return edited.isClosed ? null : 'Selecciona un horario de cierre';
            }
            if (edited.isClosed) {
              return 'El horario de cierre no puede ser definido';
            }
            if (edited.openingTime != null) {
              final int openingMinutes =
                  edited.openingTime!.hour * 60 + edited.openingTime!.minute;
              final int closingMinutes = value.hour * 60 + value.minute;
              if (closingMinutes <= openingMinutes) {
                return 'El horario de cierre debe ser posterior al de apertura';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
