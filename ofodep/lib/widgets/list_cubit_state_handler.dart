import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/repositories/abstract_repository.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';

/// Widget genérico para manejar páginas basadas en ListCubit con paginación, filtrado y búsqueda.
class ListCubitStateHandler<T extends ModelComponent,
    C extends ListCubit<T, Repository<T>>> extends StatelessWidget {
  /// Título que se muestra en el AppBar.
  final String? title;

  /// Widget opcional para construir el title del AppBar.
  final Widget? titleBuilder;

  /// Bandera para indicar si se debe de mostrar la appbar.
  final bool showAppBar;

  /// Función que crea la instancia del cubit.
  final C Function(BuildContext context) createCubit;

  /// Función que define cómo se renderiza cada item de la lista.
  final Widget Function(
    BuildContext context,
    C cubit,
    T item,
    int index,
  ) itemBuilder;

  /// Bandera para indicar si se debe de mostrar la barra de busqueda.
  final bool showSearchBar;

  /// Bandera para indicar si se debe de mostrar el botón para abrir los filtros en un bottom sheet.
  final bool showFilterButton;

  /// Builder opcional para construir la sección de filtros y búsqueda.
  final Widget Function(
    BuildContext context,
    C cubit,
    ListState state,
  ) filterSectionBuilder;

  final Widget Function(BuildContext context, C cubit, ListState state)?
      customHeader;

  /// Funión opcional al agregar un elemento.
  final void Function(
    BuildContext context,
    C cubit,
  )? onAdd;

  /// Función opcional al buscar.
  final void Function(C cubit, String search)? onSearch;

  const ListCubitStateHandler({
    super.key,
    this.title,
    this.titleBuilder,
    this.showAppBar = true,
    required this.createCubit,
    required this.itemBuilder,
    this.showSearchBar = true,
    this.showFilterButton = true,
    this.onAdd,
    this.filterSectionBuilder = defaultFilterSectionBuilder,
    this.customHeader,
    this.onSearch,
  });

  /// Sección por defecto para filtros y búsqueda.
  static Widget defaultFilterSectionBuilder(
    BuildContext context,
    ListCubit cubit,
    ListState state,
  ) {
    return CustomListView(
      children: [
        Text('Ordenar por: '),
        SegmentedButton<String?>(
          segments: const [
            ButtonSegment(
              value: 'updated_at',
              label: Text('Actualización'),
            ),
            ButtonSegment(
              value: 'created_at',
              label: Text('Creación'),
            ),
          ],
          selected: {state.orderBy},
          onSelectionChanged: (orderBy) {
            cubit.updateOrdering(orderBy: orderBy.first);
          },
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
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
      create: createCubit,
      child: Builder(
        builder: (context) {
          final cubit = context.read<C>();
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                if (showAppBar)
                  SliverAppBar(
                    title: titleBuilder ?? Text(title ?? ''),
                    floating: true,
                    snap: true,
                    actions: [
                      if (onAdd != null)
                        IconButton.filledTonal(
                          onPressed: () => onAdd!(context, cubit),
                          icon: const Icon(Icons.add),
                        ),
                      if (showFilterButton)
                        IconButton(
                          onPressed: cubit.refresh,
                          icon: const Icon(Icons.refresh),
                        ),
                      if (showFilterButton)
                        IconButton(
                          onPressed: () => showBottomSheet(
                            constraints: const BoxConstraints(
                              maxHeight: 300,
                            ),
                            context: context,
                            builder: (context) => BlocBuilder<C, ListState>(
                              bloc: cubit,
                              builder: (context, cubitState) =>
                                  filterSectionBuilder(
                                context,
                                cubit,
                                cubitState,
                              ),
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
                                onChanged: (value) => onSearch != null
                                    ? onSearch!(cubit, value)
                                    : cubit.updateSearch(value),
                              ),
                            ),
                          ),
                  )
                else if (showSearchBar)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ListTile(
                        title: TextField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search),
                            labelText: 'Buscar',
                          ),
                          onChanged: (value) => onSearch != null
                              ? onSearch!(cubit, value)
                              : cubit.updateSearch(value),
                        ),
                      ),
                    ),
                  ),
                if (customHeader != null)
                  SliverToBoxAdapter(
                    child: customHeader!(context, cubit, cubit.state),
                  ),
              ];
            },
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => cubit.refresh(),
                child: PagingListener(
                  controller: cubit.pagingController,
                  builder: (context, pagingState, fetchNextPage) {
                    return PagedListView<int, T>(
                      state: pagingState,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<T>(
                        itemBuilder: (context, item, index) =>
                            itemBuilder(context, cubit, item, index),
                        firstPageErrorIndicatorBuilder: (context) =>
                            MessagePage.error(
                          onBack: cubit.refresh,
                        ),
                        noItemsFoundIndicatorBuilder: (context) =>
                            MessagePage.warning(
                          'No se encontraron elementos',
                          onRetry: cubit.refresh,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
