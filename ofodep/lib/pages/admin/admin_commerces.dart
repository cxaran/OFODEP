import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/catalogs/commerces_list_cubit.dart';
import 'package:ofodep/models/comercio.dart';

class AdminCommercesPage extends StatefulWidget {
  const AdminCommercesPage({super.key});

  @override
  State<AdminCommercesPage> createState() => _AdminCommercesPageState();
}

class _AdminCommercesPageState extends State<AdminCommercesPage> {
  String? _selectedOrder;
  bool _ascending = false;
  DateTime? _createdAtGte;
  DateTime? _createdAtLte;

  // Método que arma y actualiza el filtro combinado.
  void updateFilters() {
    Map<String, dynamic> filter = {};
    if (_createdAtGte != null) {
      filter['created_at_gte'] = _createdAtGte!.toIso8601String();
    }
    if (_createdAtLte != null) {
      filter['created_at_lte'] = _createdAtLte!.toIso8601String();
    }
    context
        .read<CommercesListCubit>()
        .updateFilter(filter.isEmpty ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommercesListCubit>(
      create: (context) => CommercesListCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Administrar Comercios'),
          ),
          body: Column(
            children: [
              // Sección de filtros, búsqueda y ordenamiento.
              Column(
                children: [
                  // Campo de búsqueda (por nombre o descripción).
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre o descripción',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context.read<CommercesListCubit>().updateSearch(value);
                    },
                  ),

                  // Filtros de ordenamiento.
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
                            context.read<CommercesListCubit>().updateOrdering(
                                  orderBy: value,
                                  ascending: _ascending,
                                );
                          },
                        ),
                      ),

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
                              context.read<CommercesListCubit>().updateOrdering(
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
              // Lista de comercios con scroll infinito.
              Expanded(
                child:
                    BlocConsumer<CommercesListCubit, CommercesListFilterState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<CommercesListCubit>();
                    return RefreshIndicator(
                      onRefresh: () async => cubit.pagingController.refresh(),
                      child: PagingListener(
                        controller: cubit.pagingController,
                        builder: (context, state, fetchNextPage) =>
                            PagedListView<int, Comercio>(
                          state: state,
                          fetchNextPage: fetchNextPage,
                          builderDelegate: PagedChildBuilderDelegate<Comercio>(
                            itemBuilder: (context, comercio, index) => ListTile(
                              title: Text(comercio.nombre),
                              subtitle: Text(comercio.direccionCalle ?? ''),
                              trailing: const Icon(Icons.map),
                              onTap: () =>
                                  context.push('/comercio/${comercio.id}'),
                            ),
                            firstPageErrorIndicatorBuilder: (context) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Error al cargar comercios'),
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
                                    child: Text('No se encontraron comercios')),
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
              builder: (context) {
                String newName = '';
                return AlertDialog(
                  title: const Text('Agregar Comercio'),
                  content: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del comercio',
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
                          context.read<CommercesListCubit>().addCommerce(
                                nombre: newName,
                              );
                        }
                      },
                      child: const Text('Agregar'),
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
