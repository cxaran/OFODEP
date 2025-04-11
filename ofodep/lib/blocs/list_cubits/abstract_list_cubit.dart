import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

abstract class ListCubit<T extends ModelComponent, R extends Repository<T>>
    extends Cubit<ListState<T>> {
  /// El repositorio de la lista.
  final R repository;

  /// El controlador de paginación.
  late final PagingController<int, T> pagingController;

  ListCubit({
    required this.repository,
    ListState<T>? initialState,
  }) : super(initialState ?? FilterState<T>()) {
    pagingController = PagingController<int, T>(
      getNextPageKey: (statePagination) {
        final currentPage = statePagination.keys?.last ?? 0;
        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        try {
          final newItems = await getPaginated(
            page: pageKey,
            limit: state.limit,
            filter: state.filter,
            search: state.search,
            orderBy: state.orderBy,
            ascending: state.ascending,
          );
          if (newItems.isEmpty) {
            pagingController.value = pagingController.value.copyWith(
              hasNextPage: false,
            );
          }
          return newItems;
        } catch (e) {
          emit(state.copyWith(errorMessage: e.toString()));
          pagingController.value =
              pagingController.value.copyWith(hasNextPage: false);
          return <T>[];
        }
      },
    );
  }

  /// Refresca la paginación.
  void refresh() {
    pagingController.refresh();
  }

  /// Actualizar los campos de búsqueda y refresca la paginación.
  void updateSearchFields(List<String>? searchFields) {
    emit(state.copyWith(searchFields: searchFields));
    refresh();
  }

  /// Actualizar los campos de búsqueda y refresca la paginación.
  void updateArraySearchFields(List<String>? arraySearchFields) {
    emit(state.copyWith(arraySearchFields: arraySearchFields));
    refresh();
  }

  /// Actualiza el término de búsqueda y refresca la paginación.
  void updateSearch(String? search) {
    emit(state.copyWith(search: search));
    refresh();
  }

  /// Actualiza los filtros y refresca la paginación.
  void updateFilter(Map<String, dynamic>? filter) {
    emit(state.copyWith(filter: filter));
    refresh();
  }

  /// Actualiza el ordenamiento y refresca la paginación.
  void updateOrdering({String? orderBy, bool? ascending}) {
    emit(state.copyWith(orderBy: orderBy, ascending: ascending));
    refresh();
  }

  /// Actualiza la semilla aleatoria y refresca la paginación.
  void updateRandomSeed(String? seed) {
    emit(state.copyWith(randomSeed: seed));
    refresh();
  }

  /// Obtener el filtro con parámetros persobalizados si aplica.
  Map<String, dynamic>? getFilter(Map<String, dynamic>? filter) {
    return filter;
  }

  /// Actualiza el estado de la lista.
  Future<List<T>> getPaginated({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) {
    if (state.randomSeed != null) {
      return repository.getRandom(
        page: page,
        limit: limit,
        filter: getFilter(filter),
        search: search,
        orderBy: orderBy,
        ascending: ascending,
        randomSeed: state.randomSeed,
        params: state.rpcParams,
      );
    } else {
      return repository.getPaginated(
        page: page,
        limit: limit,
        filter: getFilter(filter),
        search: search,
        orderBy: orderBy,
        ascending: ascending,
        params: state.rpcParams,
      );
    }
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
