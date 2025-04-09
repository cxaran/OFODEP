import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';

/// Widget genérico para manejar páginas basadas en ListCubit con paginación, filtrado y búsqueda.
class ListCubitStateHandler<T extends ModelComponent> extends StatelessWidget {
  /// Título que se muestra en el AppBar.
  final String? title;

  /// Widget opcional para construir el title del AppBar.
  final Widget? titleBuilder;

  /// Bandera para indicar si se debe de mostrar la appbar.
  final bool showAppBar;

  /// Función que crea la instancia del cubit.
  final ListCubit<T> Function(BuildContext context) createCubit;

  /// Función que define cómo se renderiza cada item de la lista.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Bandera para indicar si se debe de mostrar la barra de busqueda.
  final bool showSearchBar;

  /// Bandera para indicar si se debe de mostrar el botón para abrir los filtros en un bottom sheet.
  final bool showFilterButton;

  /// Builder opcional para construir la sección de filtros y búsqueda.
  final Widget Function(
    BuildContext context,
    ListCubit<T> cubit,
    ListState<T> state,
  )? filterSectionBuilder;

  /// Builder opcional opciones extra en la sección de filtros por defecto. Se agregan despues de los filtros por defecto.
  final Widget Function(
    BuildContext context,
    ListCubit<T> cubit,
    ListState<T> state,
  )? filterActionsBuilder;

  /// Bandera para indicar si se debe de mostrar el botón de agregar.
  final bool showAddButton;

  /// Funión opcional al agregar un elemento.
  final void Function(
    BuildContext context,
    ListCubit<T> cubit,
  )? onAdd;

  const ListCubitStateHandler({
    super.key,
    this.title,
    this.titleBuilder,
    this.showAppBar = true,
    required this.createCubit,
    required this.itemBuilder,
    this.showSearchBar = true,
    this.showFilterButton = true,
    this.showAddButton = true,
    this.onAdd,
    this.filterSectionBuilder,
    this.filterActionsBuilder,
  });

  /// Sección por defecto para filtros y búsqueda.
  Widget defaultFilterSectionBuilder(
      BuildContext context, ListCubit<T> cubit, ListState<T> _) {
    return BlocBuilder<ListCubit<T>, ListState<T>>(
      bloc: cubit,
      builder: (context, state) {
        return CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'name', label: Text('Nombre')),
                ButtonSegment(value: 'created_at', label: Text('Creación')),
              ],
              selected: {state.orderBy ?? 'created_at'},
              onSelectionChanged: (newSelection) {
                cubit.updateOrdering(orderBy: newSelection.first);
              },
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Ascendente')),
                ButtonSegment(value: false, label: Text('Descendente')),
              ],
              selected: {state.ascending},
              onSelectionChanged: (newSelection) {
                cubit.updateOrdering(ascending: newSelection.first);
              },
            ),
            Divider(),
            // Se agregan acciones adicionales si se definen.
            if (filterActionsBuilder != null)
              filterActionsBuilder!(context, cubit, state),
          ],
        );
      },
    );
  }

  /// Funcion default para agregar un elemento. Se invoca el callback de onAdd si se ha definido.
  void defaultOnAdd(BuildContext context, ListCubit<T> cubit) {}

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListCubit<T>>(
      create: createCubit,
      child: Builder(
        builder: (context) {
          final cubit = context.read<ListCubit<T>>();
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                if (showAppBar)
                  SliverAppBar(
                    title: titleBuilder ?? Text(title ?? ''),
                    floating: true,
                    snap: true,
                    actions: [
                      if (showFilterButton)
                        IconButton(
                          onPressed: () => showBottomSheet(
                            constraints: const BoxConstraints(
                              maxHeight: 300,
                            ),
                            context: context,
                            builder: (context) => defaultFilterSectionBuilder(
                              context,
                              cubit,
                              cubit.state,
                            ),
                          ),
                          icon: const Icon(Icons.tune),
                        ),
                      gap,
                    ],
                    bottom: !showSearchBar
                        ? null
                        : PreferredSize(
                            preferredSize: const Size.fromHeight(48),
                            child: ListTile(
                              title: TextField(
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.search),
                                  labelText: 'Buscar',
                                ),
                                onChanged: (value) => cubit.updateSearch(value),
                              ),
                            ),
                          ),
                  ),
              ];
            },
            body: RefreshIndicator(
              onRefresh: () async => cubit.refresh(),
              child: PagingListener(
                controller: cubit.pagingController,
                builder: (context, pagingState, fetchNextPage) {
                  return PagedListView<int, T>(
                    state: pagingState,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<T>(
                      itemBuilder: (context, item, index) =>
                          itemBuilder(context, item, index),
                      firstPageErrorIndicatorBuilder: (context) =>
                          MessagePage.error(onBack: cubit.refresh),
                      noItemsFoundIndicatorBuilder: (context) =>
                          MessagePage.warning('No se encontraron elementos'),
                      // noMoreItemsIndicatorBuilder: (context) => Divider(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
