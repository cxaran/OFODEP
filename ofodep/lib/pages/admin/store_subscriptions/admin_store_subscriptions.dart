import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/store_subscriptions_list_cubit.dart';
import 'package:ofodep/models/store_subscription_model.dart';

class AdminStoreSubscriptionsAdminPage extends StatefulWidget {
  const AdminStoreSubscriptionsAdminPage({super.key});

  @override
  State<AdminStoreSubscriptionsAdminPage> createState() =>
      _AdminStoreSubscriptionsAdminPageState();
}

class _AdminStoreSubscriptionsAdminPageState
    extends State<AdminStoreSubscriptionsAdminPage> {
  String? _selectedOrder;
  bool _ascending = false;
  DateTime? _createdAtGte;
  DateTime? _createdAtLte;

  /// Builds and updates the combined filter.
  void updateFilters() {
    Map<String, dynamic> filter = {};
    if (_createdAtGte != null) {
      filter['created_at#gte'] = _createdAtGte!.toIso8601String();
    }
    if (_createdAtLte != null) {
      filter['created_at#lte'] = _createdAtLte!.toIso8601String();
    }
    context
        .read<StoreSubscriptionsListCubit>()
        .updateFilter(filter.isEmpty ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoreSubscriptionsListCubit>(
      create: (context) => StoreSubscriptionsListCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('subscriptions'),
          ),
          body: Column(
            children: [
              // Filtros, search, and ordering section

              Column(
                children: [
                  // Search field (by name or description)
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'search',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context
                          .read<StoreSubscriptionsListCubit>()
                          .updateSearch(value);
                    },
                  ),
                  // Sorting filters
                  Row(
                    children: [
                      // Dropdown to select sorting criteria
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedOrder,
                          decoration: const InputDecoration(
                            labelText: 'sort_by',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'created_at',
                              child: Text('created_at'),
                            ),
                            DropdownMenuItem(
                              value: 'updated_at',
                              child: Text('updated_at'),
                            ),
                            DropdownMenuItem(
                              value: 'subscription_type',
                              child: Text('subscription_type'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedOrder = value;
                            });
                            context
                                .read<StoreSubscriptionsListCubit>()
                                .updateOrdering(
                                  orderBy: value,
                                  ascending: _ascending,
                                );
                          },
                        ),
                      ),

                      Column(
                        children: [
                          const Text('ascending'),
                          Switch(
                            value: _ascending,
                            onChanged: (value) {
                              setState(() {
                                _ascending = value;
                              });
                              context
                                  .read<StoreSubscriptionsListCubit>()
                                  .updateOrdering(
                                    orderBy: _selectedOrder,
                                    ascending: _ascending,
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Date range filters (optional example)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                _createdAtGte = selectedDate;
                              });
                              updateFilters();
                            }
                          },
                          child: Text(_createdAtGte == null
                              ? 'created_after...'
                              : 'created_after: ${_createdAtGte!.toLocal()}'),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                _createdAtLte = selectedDate;
                              });
                              updateFilters();
                            }
                          },
                          child: Text(_createdAtLte == null
                              ? 'created_before...'
                              : 'created_before: ${_createdAtLte!.toLocal()}'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Lista de usuarios con scroll infinito.
              Expanded(
                child: BlocConsumer<StoreSubscriptionsListCubit,
                    BasicListFilterState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<StoreSubscriptionsListCubit>();
                    return RefreshIndicator(
                      onRefresh: () async => cubit.pagingController.refresh(),
                      child: PagingListener(
                        controller: cubit.pagingController,
                        builder: (context, state, fetchNextPage) =>
                            PagedListView<int, StoreSubscriptionModel>(
                          state: state,
                          fetchNextPage: fetchNextPage,
                          builderDelegate:
                              PagedChildBuilderDelegate<StoreSubscriptionModel>(
                            itemBuilder: (context, subscription, index) =>
                                ListTile(
                              title: Text(subscription.storeName),
                              subtitle: Text(
                                subscription.subscriptionType.description,
                              ),
                              trailing: Text(
                                subscription.expirationDate
                                    .toLocal()
                                    .toString(),
                              ),
                              onTap: () => context.push(
                                '/admin/subscription/${subscription.storeId}',
                              ),
                            ),
                            firstPageErrorIndicatorBuilder: (context) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('error_loading'),
                                  ElevatedButton(
                                    onPressed: () =>
                                        cubit.pagingController.refresh(),
                                    child: const Text('retry'),
                                  ),
                                ],
                              ),
                            ),
                            noItemsFoundIndicatorBuilder: (context) =>
                                const Center(
                              child: Text('not_found'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
