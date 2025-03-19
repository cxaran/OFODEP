import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/catalogs/users_list_cubit.dart';
import 'package:ofodep/models/usuario.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedOrder;
  bool _ascending = false;
  bool _adminFilter = false;
  DateTime? _createdAtGte;
  DateTime? _createdAtLte;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Construye el mapa de filtros combinando los valores actuales.
  void updateFilters() {
    Map<String, dynamic> filter = {};
    if (_adminFilter) filter['admin'] = true;
    if (_createdAtGte != null) {
      filter['created_at_gte'] = _createdAtGte!.toIso8601String();
    }
    if (_createdAtLte != null) {
      filter['created_at_lte'] = _createdAtLte!.toIso8601String();
    }
    context.read<UsersListCubit>().updateFilter(filter.isEmpty ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsersListCubit>(
      create: (context) => UsersListCubit(),
      child: Builder(builder: (context) => _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Usuarios'),
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          _buildUsersListSection(),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Campo de búsqueda.
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar por nombre, email o teléfono',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<UsersListCubit>().updateSearch(value);
            },
          ),
          const SizedBox(height: 8),
          // Filtros de fecha: "Fecha Desde" y "Fecha Hasta".
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _createdAtGte ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _createdAtGte = selectedDate;
                      });
                      updateFilters();
                    }
                  },
                  child: Text(
                    _createdAtGte == null
                        ? "Fecha Desde"
                        : "Desde: ${_createdAtGte!.toLocal().toString().split(' ')[0]}",
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _createdAtLte ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _createdAtLte = selectedDate;
                      });
                      updateFilters();
                    }
                  },
                  child: Text(
                    _createdAtLte == null
                        ? "Fecha Hasta"
                        : "Hasta: ${_createdAtLte!.toLocal().toString().split(' ')[0]}",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Filtros de ordenamiento y filtro de administradores.
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedOrder,
                  decoration: const InputDecoration(
                    labelText: 'Ordenar por',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'created_at',
                      child: Text('Fecha de creación'),
                    ),
                    DropdownMenuItem(
                      value: 'updated_at',
                      child: Text('Fecha de actualización'),
                    ),
                    DropdownMenuItem(
                      value: 'nombre',
                      child: Text('Nombre'),
                    ),
                    DropdownMenuItem(
                      value: 'email',
                      child: Text('Email'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedOrder = value;
                    });
                    context.read<UsersListCubit>().updateOrdering(
                          orderBy: value,
                          ascending: _ascending,
                        );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Text('Ascendente'),
                  Switch(
                    value: _ascending,
                    onChanged: (value) {
                      setState(() {
                        _ascending = value;
                      });
                      context.read<UsersListCubit>().updateOrdering(
                            orderBy: _selectedOrder,
                            ascending: _ascending,
                          );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Text('Solo Admin'),
                  Checkbox(
                    value: _adminFilter,
                    onChanged: (value) {
                      setState(() {
                        _adminFilter = value ?? false;
                      });
                      updateFilters();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersListSection() {
    return Expanded(
      child: BlocConsumer<UsersListCubit, UsersListFilterState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<UsersListCubit>();
          return RefreshIndicator(
            onRefresh: () async => cubit.pagingController.refresh(),
            child: PagingListener(
              controller: cubit.pagingController,
              builder: (context, pagingState, fetchNextPage) =>
                  PagedListView<int, Usuario>(
                state: pagingState,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<Usuario>(
                  itemBuilder: (context, usuario, index) => ListTile(
                    title: Text(usuario.nombre),
                    subtitle: Text(usuario.email),
                    trailing: usuario.admin
                        ? const Icon(Icons.admin_panel_settings)
                        : null,
                  ),
                  firstPageErrorIndicatorBuilder: (context) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Error al cargar usuarios'),
                        ElevatedButton(
                          onPressed: () => cubit.pagingController.refresh(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) =>
                      const Center(child: Text('No se encontraron usuarios')),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
