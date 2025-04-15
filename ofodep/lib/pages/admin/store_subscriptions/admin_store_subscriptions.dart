import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/store_subscriptions_list_cubit.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';

class AdminStoreSubscriptionsAdminPage extends StatefulWidget {
  const AdminStoreSubscriptionsAdminPage({super.key});

  @override
  State<AdminStoreSubscriptionsAdminPage> createState() =>
      _AdminStoreSubscriptionsAdminPageState();
}

class _AdminStoreSubscriptionsAdminPageState
    extends State<AdminStoreSubscriptionsAdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListCubitStateHandler<StoreSubscriptionModel,
          StoreSubscriptionsListCubit>(
        title: 'Suscripciones',
        createCubit: (context) => StoreSubscriptionsListCubit(),
        itemBuilder: (context, cubit, subscription, index) => ListTile(
          title: Text(subscription.storeName ?? ''),
          subtitle: Text(
            '${subscription.subscriptionType.description}\n'
            '${subscription.id}',
          ),
          trailing: Text(
            MaterialLocalizations.of(context).formatShortDate(
              subscription.expirationDate,
            ),
          ),
          onTap: () => context
              .push(
                '/admin/subscription/${subscription.storeId}',
              )
              .then(
                (back) => back == true ? cubit.refresh() : null,
              ),
        ),
        filterSectionBuilder: (context, cubit, state) => CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: 'created_at',
                  label: Text('Fecha'),
                ),
                ButtonSegment(
                  value: 'updated_at',
                  label: Text('Actualización'),
                ),
                ButtonSegment(
                  value: 'subscription_type',
                  label: Text('Tipo'),
                ),
              ],
              selected: {state.orderBy},
              onSelectionChanged: (orderBy) => cubit.updateOrdering(
                orderBy: orderBy.first,
              ),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Ascendente')),
                ButtonSegment(value: false, label: Text('Descendente')),
              ],
              selected: {state.ascending},
              onSelectionChanged: (ascending) => cubit.updateOrdering(
                ascending: ascending.first,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
