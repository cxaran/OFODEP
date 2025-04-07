import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/store_schedule_exceptions_list_cubit.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/pages/error_page.dart';

class AdminStoreScheduleExceptionsPage extends StatefulWidget {
  final String? storeId;
  const AdminStoreScheduleExceptionsPage({
    super.key,
    this.storeId,
  });

  @override
  State<AdminStoreScheduleExceptionsPage> createState() =>
      _AdminStoreScheduleExceptionsPageState();
}

class _AdminStoreScheduleExceptionsPageState
    extends State<AdminStoreScheduleExceptionsPage> {
  String? _selectedOrder;
  bool _ascending = false;
  DateTime? _createdAtGte;
  DateTime? _createdAtLte;

  // Este método arma el mapa de filtros combinando los valores actuales.
  void updateFilters() {
    Map<String, dynamic> filter = {};

    if (_createdAtGte != null) {
      filter['created_at#gte'] = _createdAtGte!.toIso8601String();
    }
    if (_createdAtLte != null) {
      filter['created_at#lte'] = _createdAtLte!.toIso8601String();
    }
    // Si no hay ningún filtro, se envía null
    context
        .read<StoreScheduleExceptionsListCubit>()
        .updateFilter(filter.isEmpty ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storeId == null) {
      return const ErrorPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: BlocProvider<StoreScheduleExceptionsListCubit>(
        create: (context) =>
            StoreScheduleExceptionsListCubit(storeId: widget.storeId!),
        child: Builder(
          builder: (context) => Scaffold(
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
                            .read<StoreScheduleExceptionsListCubit>()
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
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedOrder = value;
                              });
                              context
                                  .read<StoreScheduleExceptionsListCubit>()
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
                                    .read<StoreScheduleExceptionsListCubit>()
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
                  child: BlocConsumer<StoreScheduleExceptionsListCubit,
                      BasicListFilterState>(
                    listener: (context, state) {
                      if (state.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                      }
                    },
                    builder: (context, state) {
                      final cubit =
                          context.read<StoreScheduleExceptionsListCubit>();
                      return RefreshIndicator(
                        onRefresh: () async => cubit.pagingController.refresh(),
                        child: PagingListener(
                          controller: cubit.pagingController,
                          builder: (context, state, fetchNextPage) =>
                              PagedListView<int, StoreScheduleExceptionModel>(
                            state: state,
                            fetchNextPage: fetchNextPage,
                            builderDelegate: PagedChildBuilderDelegate<
                                StoreScheduleExceptionModel>(
                              itemBuilder: (context, schedule, index) =>
                                  ListTile(
                                title: Text(schedule.date
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
                                subtitle: Text(
                                  '${schedule.openingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(schedule.openingTime!)}'
                                  ' - '
                                  '${schedule.closingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(schedule.closingTime!)}',
                                ),
                                onTap: () => context.push(
                                    '/admin/schedule_exception/${schedule.id}'),
                              ),
                              firstPageErrorIndicatorBuilder: (context) =>
                                  Center(
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
            floatingActionButton: widget.storeId == null
                ? null
                : FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () =>
                        context.read<StoreScheduleExceptionsListCubit>().add(
                              StoreScheduleExceptionModel(
                                id: '',
                                storeId: widget.storeId!,
                                date: DateTime.now().subtract(
                                  const Duration(days: 1),
                                ),
                              ),
                            ),
                  ),
          ),
        ),
      ),
    );
  }
}
