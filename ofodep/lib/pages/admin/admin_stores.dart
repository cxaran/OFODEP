import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/catalogs/stores_list_cubit.dart';
import 'package:ofodep/models/store_model.dart';

class AdminStoresPage extends StatefulWidget {
  const AdminStoresPage({super.key});

  @override
  State<AdminStoresPage> createState() => _AdminStoresPageState();
}

class _AdminStoresPageState extends State<AdminStoresPage> {
  String? _selectedOrder;
  bool _ascending = false;
  DateTime? _createdAtGte;
  DateTime? _createdAtLte;

  /// Builds and updates the combined filter.
  void updateFilters() {
    Map<String, dynamic> filter = {};
    if (_createdAtGte != null) {
      filter['created_at_gte'] = _createdAtGte!.toIso8601String();
    }
    if (_createdAtLte != null) {
      filter['created_at_lte'] = _createdAtLte!.toIso8601String();
    }
    context
        .read<StoresListCubit>()
        .updateFilter(filter.isEmpty ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoresListCubit>(
      create: (context) => StoresListCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Manage Stores'),
          ),
          body: Column(
            children: [
              // Filters, search, and sorting section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Search field (by name or description)
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search by name or description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        context.read<StoresListCubit>().updateSearch(value);
                      },
                    ),
                    const SizedBox(height: 8),
                    // Sorting filters
                    Row(
                      children: [
                        // Dropdown to select sorting criteria
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedOrder,
                            decoration: const InputDecoration(
                              labelText: 'Sort by',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'created_at',
                                child: Text('Creation date'),
                              ),
                              DropdownMenuItem(
                                value: 'updated_at',
                                child: Text('Update date'),
                              ),
                              DropdownMenuItem(
                                value: 'name',
                                child: Text('Name'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedOrder = value;
                              });
                              context.read<StoresListCubit>().updateOrdering(
                                    orderBy: value,
                                    ascending: _ascending,
                                  );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            const Text('Ascending'),
                            Switch(
                              value: _ascending,
                              onChanged: (value) {
                                setState(() {
                                  _ascending = value;
                                });
                                context.read<StoresListCubit>().updateOrdering(
                                      orderBy: _selectedOrder,
                                      ascending: _ascending,
                                    );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                                ? 'Created after...'
                                : 'Created after: ${_createdAtGte!.toLocal()}'),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                ? 'Created before...'
                                : 'Created before: ${_createdAtLte!.toLocal()}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Infinite scroll list of stores
              Expanded(
                child: BlocConsumer<StoresListCubit, StoresListFilterState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                    if (state.newElementId != null) {
                      if (mounted) {
                        context.push('/admin/store/${state.newElementId}');
                      }
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<StoresListCubit>();
                    return RefreshIndicator(
                      onRefresh: () async => cubit.pagingController.refresh(),
                      child: PagingListener(
                        controller: cubit.pagingController,
                        builder: (context, pagingState, fetchNextPage) =>
                            PagedListView<int, StoreModel>(
                          state: pagingState,
                          fetchNextPage: fetchNextPage,
                          builderDelegate:
                              PagedChildBuilderDelegate<StoreModel>(
                            itemBuilder: (context, store, index) => ListTile(
                              title: Text(store.name),
                              subtitle: Text(store.addressStreet ?? ''),
                              trailing: const Icon(Icons.map),
                              onTap: () =>
                                  context.push('/admin/store/${store.id}'),
                            ),
                            firstPageErrorIndicatorBuilder: (context) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Error loading stores'),
                                  ElevatedButton(
                                    onPressed: () =>
                                        cubit.pagingController.refresh(),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                            noItemsFoundIndicatorBuilder: (context) =>
                                const Center(child: Text('No stores found')),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (dialogContext) {
                String newName = '';
                return AlertDialog(
                  title: const Text('Add Store'),
                  content: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Store name',
                    ),
                    onChanged: (value) => newName = value,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(null);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (newName.isNotEmpty) {
                          context.read<StoresListCubit>().addStore(
                                name: newName,
                              );
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
