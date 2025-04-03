import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_subscription_cubit.dart';
import 'package:ofodep/models/enums.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/pages/error_page.dart';

class StoreSubscriptionsAdminPage extends StatefulWidget {
  final String? storeId;
  const StoreSubscriptionsAdminPage({super.key, this.storeId});

  @override
  State<StoreSubscriptionsAdminPage> createState() =>
      _StoreSubscriptionsAdminPageState();
}

class _StoreSubscriptionsAdminPageState
    extends State<StoreSubscriptionsAdminPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.storeId == null) return const ErrorPage();

    return BlocProvider<StoreSubscriptionCubit>(
      create: (context) => StoreSubscriptionCubit(id: widget.storeId!)..load(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<StoreSubscriptionCubit,
              CrudState<StoreSubscriptionModel>>(
            listener: (context, state) {
              if (state is CrudError<StoreSubscriptionModel>) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is CrudEditing<StoreSubscriptionModel> &&
                  state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
              if (state is CrudDeleted<StoreSubscriptionModel>) {
                // Por ejemplo, se puede redirigir a otra pantalla al eliminar
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              if (state is CrudInitial<StoreSubscriptionModel> ||
                  state is CrudLoading<StoreSubscriptionModel>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CrudError<StoreSubscriptionModel>) {
                return Center(child: Text(state.message));
              } else if (state is CrudLoaded<StoreSubscriptionModel>) {
                // Estado no editable: muestra los datos y un botón para editar
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Store: ${state.model.storeName}"),
                      Text(
                          "Subscription Type: ${state.model.subscriptionType.description}"),
                      Text("Expiration Date: ${state.model.expirationDate}"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context
                            .read<StoreSubscriptionCubit>()
                            .startEditing(),
                        child: const Text("Editar"),
                      ),
                    ],
                  ),
                );
              } else if (state is CrudEditing<StoreSubscriptionModel>) {
                // En modo edición, se usan TextFields que muestran los valores de editedModel.
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButton(
                          value: state.editedModel.subscriptionType,
                          items: [
                            for (final subscriptionType
                                in SubscriptionType.values)
                              DropdownMenuItem(
                                value: subscriptionType,
                                child: Text(subscriptionType.description),
                              ),
                          ],
                          onChanged: (value) => context
                              .read<StoreSubscriptionCubit>()
                              .updateEditingState((model) =>
                                  model.copyWith(subscriptionType: value))),
                      // ExpirationDate
                      ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () async {
                                final storeSubscriptionCubit =
                                    context.read<StoreSubscriptionCubit>();
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (selectedDate != null && mounted) {
                                  storeSubscriptionCubit.updateEditingState(
                                      (model) => model.copyWith(
                                          expirationDate: selectedDate));
                                }
                              },
                        child: Text(state.editedModel.expirationDate
                            .toLocal()
                            .toString()),
                      ),
                      ElevatedButton(
                        onPressed: state.isSubmitting || !state.editMode
                            ? null
                            : () =>
                                context.read<StoreSubscriptionCubit>().submit(),
                        child: state.isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text("Guardar"),
                      ),
                      ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => context
                                .read<StoreSubscriptionCubit>()
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
          );
        },
      ),
    );
  }
}
