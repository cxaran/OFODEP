import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/catalogs/zones_list_cubit.dart';
import 'package:ofodep/models/zona.dart';

class AdminZonesPage extends StatefulWidget {
  const AdminZonesPage({super.key});

  @override
  State<AdminZonesPage> createState() => _AdminZonesPageState();
}

class _AdminZonesPageState extends State<AdminZonesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedOrder;
  bool _ascending = false;
  DateTime? _createdAtGte;
  DateTime? _createdAtLte;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método que arma y actualiza el filtro combinado.
  void updateFilters() {
    Map<String, dynamic> filter = {};
    if (_createdAtGte != null) {
      filter['created_at_gte'] = _createdAtGte!.toIso8601String();
    }
    if (_createdAtLte != null) {
      filter['created_at_lte'] = _createdAtLte!.toIso8601String();
    }
    context.read<ZonesListCubit>().updateFilter(filter.isEmpty ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZonesListCubit>(
      create: (context) => ZonesListCubit(),
      child: Builder(
        builder: (context) =>
            BlocListener<ZonesListCubit, ZonesListFilterState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Administrar Zonas'),
            ),
            body: Column(
              children: [
                // Sección de filtros, búsqueda y ordenamiento.
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Campo de búsqueda (por nombre o descripción).
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar por nombre o descripción',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          context.read<ZonesListCubit>().updateSearch(value);
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
                      Row(
                        children: [
                          // Dropdown para seleccionar el criterio de ordenamiento.
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
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedOrder = value;
                                });
                                context.read<ZonesListCubit>().updateOrdering(
                                      orderBy: value,
                                      ascending: _ascending,
                                    );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Switch para definir orden ascendente/descendente.
                          Column(
                            children: [
                              const Text('Ascendente'),
                              Switch(
                                value: _ascending,
                                onChanged: (value) {
                                  setState(() {
                                    _ascending = value;
                                  });
                                  context.read<ZonesListCubit>().updateOrdering(
                                        orderBy: _selectedOrder,
                                        ascending: _ascending,
                                      );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Lista de zonas con scroll infinito.
                Expanded(
                  child: BlocBuilder<ZonesListCubit, ZonesListFilterState>(
                    builder: (context, state) {
                      final cubit = context.read<ZonesListCubit>();
                      return RefreshIndicator(
                        onRefresh: () async => cubit.pagingController.refresh(),
                        child: PagingListener(
                          controller: cubit.pagingController,
                          builder: (context, state, fetchNextPage) =>
                              PagedListView<int, Zona>(
                            state: state,
                            fetchNextPage: fetchNextPage,
                            builderDelegate: PagedChildBuilderDelegate<Zona>(
                              itemBuilder: (context, zona, index) => ListTile(
                                title: Text(zona.nombre),
                                subtitle: Text(zona.descripcion ?? ''),
                                trailing: const Icon(Icons.map),
                              ),
                              firstPageErrorIndicatorBuilder: (context) =>
                                  Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Error al cargar zonas'),
                                    ElevatedButton(
                                      onPressed: () =>
                                          cubit.pagingController.refresh(),
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              ),
                              noItemsFoundIndicatorBuilder: (context) =>
                                  const Center(
                                      child: Text('No se encontraron zonas')),
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
              onPressed: () async {
                final zoneName = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String newName = '';
                    return AlertDialog(
                      title: const Text('Agregar Zona'),
                      content: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la zona',
                        ),
                        onChanged: (value) => newName = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (newName.isNotEmpty) {
                              Navigator.of(context).pop(newName);
                            }
                          },
                          child: const Text('Agregar'),
                        ),
                      ],
                    );
                  },
                );

                if (zoneName != null) {
                  context.read<ZonesListCubit>().addZone(zoneName);
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
