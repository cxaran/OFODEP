import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_subscription_cubit.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/models/enums.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/admin_global_repository.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_form_validator.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';

class StoreSubscriptionAdminPage extends StatelessWidget {
  final String? storeId;
  StoreSubscriptionAdminPage({super.key, this.storeId});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: CrudStateHandler<StoreSubscriptionModel, StoreSubscriptionCubit>(
        createCubit: (context) => StoreSubscriptionCubit()..load(storeId!),
        loadedBuilder: loadedBuilder,
        // editingBuilder: editingBuilder,
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    StoreSubscriptionCubit cubit,
    CrudLoaded<StoreSubscriptionModel> state,
  ) {
    final model = state.model;
    UserModel? user = context.read<SessionCubit>().user;

    if (user == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return FutureBuilder(
      future: AdminGlobalRepository().getById(user.authId),
      builder: (context, snapshot) {
        return CustomListView(
          title: 'Suscripcion',
          actions: [
            if (snapshot.connectionState == ConnectionState.done)
              if (snapshot.hasData && snapshot.data != null)
                ElevatedButton.icon(
                  onPressed: () => cubit.startEditing(),
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                ),
          ],
          children: [
            ListTile(
              leading: const Icon(Icons.storefront),
              title: Text('Tienda'),
              subtitle: Text(model.storeName),
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.card_membership),
              title: Text('Tipo'),
              subtitle: Text(
                model.subscriptionType.description.toUpperCase(),
              ),
            ),
            ListTile(
              leading: model.expirationDate.isBefore(DateTime.now())
                  ? Badge(
                      label: Text('!'),
                      child: const Icon(Icons.calendar_today),
                    )
                  : const Icon(Icons.calendar_today),
              title: Text('Fecha de expiración'),
              subtitle: Text(
                MaterialLocalizations.of(context).formatCompactDate(
                  model.expirationDate,
                ),
              ),
            ),
            if (model.expirationDate.isBefore(DateTime.now())) const Divider(),
            if (model.expirationDate.isBefore(DateTime.now()))
              ListTile(
                leading: Icon(
                  Icons.warning_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'La suscripción ha expirado si desea renovarla, si usted es el administrador de la tienda, puede renovar la suscripción poniendose en contacto con nosotros.',
                ),
              ),
          ],
        );
      },
    );
  }

  Widget editingBuilder(
    BuildContext context,
    StoreSubscriptionCubit cubit,
    CrudEditing<StoreSubscriptionModel> state,
  ) {
    final edited = state.editedModel;
    return CustomListView(
      title: 'Suscripcion',
      formKey: formKey,
      isLoading: state.isSubmitting,
      editMode: state.editMode,
      onSave: () => submit(formKey, cubit),
      onBack: cubit.cancelEditing,
      children: [
        DropdownButtonFormField<SubscriptionType>(
          decoration: const InputDecoration(
            labelText: 'Tipo de suscripción',
            border: OutlineInputBorder(),
          ),
          value: edited.subscriptionType,
          items: SubscriptionType.values
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.description.toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(subscriptionType: value),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          ).then((date) => cubit.updateEditedModel(
                (model) => model.copyWith(expirationDate: date),
              )),
          label: Text(
            'Fecha de expiración: '
            '${MaterialLocalizations.of(context).formatCompactDate(
              edited.expirationDate,
            )}',
          ),
          icon: const Icon(Icons.calendar_today),
        ),
        CustomFormValidator(
          initialValue: edited.expirationDate,
          validator: (value) {
            if (value == null) return 'Selecciona una fecha';
            if (edited.expirationDate.isBefore(DateTime.now())) {
              return 'La fecha de expiración debe ser en el futuro';
            }
            return null;
          },
        ),
      ],
    );
  }
}
