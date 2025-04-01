import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/products_list_cubit.dart';
import 'package:ofodep/models/product_model.dart';

class AdminProductsPage extends StatefulWidget {
  final String? storeId;
  const AdminProductsPage({
    super.key,
    this.storeId,
  });

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
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
        .read<ProductsListCubit>()
        .updateFilter(filter.isEmpty ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsListCubit>(
      create: (context) => ProductsListCubit(storeId: widget.storeId),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('products'),
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
                      context.read<ProductsListCubit>().updateSearch(value);
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
                              value: 'name',
                              child: Text('name'),
                            ),
                            DropdownMenuItem(
                              value: 'category',
                              child: Text('category'),
                            ),
                            DropdownMenuItem(
                              value: 'price',
                              child: Text('price'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedOrder = value;
                            });
                            context.read<ProductsListCubit>().updateOrdering(
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
                              context.read<ProductsListCubit>().updateOrdering(
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
                child: BlocConsumer<ProductsListCubit, BasicListFilterState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<ProductsListCubit>();
                    return RefreshIndicator(
                      onRefresh: () async => cubit.pagingController.refresh(),
                      child: PagingListener(
                        controller: cubit.pagingController,
                        builder: (context, state, fetchNextPage) =>
                            PagedListView<int, ProductModel>(
                          state: state,
                          fetchNextPage: fetchNextPage,
                          builderDelegate:
                              PagedChildBuilderDelegate<ProductModel>(
                            itemBuilder: (context, product, index) => ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                '${product.category ?? ''}\n'
                                '${widget.storeId == null ? '${product.storeName}\n' : ''}'
                                // '${widget.storeId == null ? '${product.zipcodes?.join(',') ?? ''}\n' : ''}'
                                '${product.description ?? ''}',
                              ),
                              trailing: Text(product.price?.toString() ?? ''),
                              onTap: () => context.push(
                                '/admin/product/${product.id}',
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
                              child: Text('error_not_found'),
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
                  onPressed: () async {
                    final cubit = context.read<ProductsListCubit>();

                    ProductModel? product = await showDialog(
                      context: context,
                      builder: (context) {
                        return ProductsAdd(
                          storeId: widget.storeId!,
                        );
                      },
                    );

                    if (product != null) {
                      cubit.addProduct(
                        name: product.name,
                        description: product.description,
                        price: product.price,
                        storeId: product.storeId,
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}

class ProductsAdd extends StatelessWidget {
  final String storeId;
  final _formKey = GlobalKey<FormState>();

  ProductsAdd({super.key, required this.storeId});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(ProductModel(
                      id: '',
                      storeId: storeId,
                      storeName: '',
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.parse(priceController.text),
                    ));
                  }
                },
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
