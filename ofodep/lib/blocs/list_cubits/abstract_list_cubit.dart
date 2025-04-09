import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

abstract class ListCubit<T extends ModelComponent> extends Cubit<ListState<T>> {
  final Repository<T> repository;
  late final PagingController<int, T> pagingController;
  final int limit;
  String? randomSeed;

  ListCubit({
    required ListState<T> initialState,
    required this.repository,
    this.limit = 10,
    this.randomSeed,
  }) : super(initialState) {
    pagingController = PagingController<int, T>(
      getNextPageKey: (state) {
        final currentPage = state.keys?.last ?? 0;
        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        try {
          final newItems = await getPaginated(
            page: pageKey,
            limit: limit,
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

  /// Actualiza la semilla aleatoria y refresca la paginación.
  void updateRandomSeed(String? seed) {
    randomSeed = seed;
    refresh();
  }

  /// Refresca la paginación.
  void refresh() {
    pagingController.refresh();
  }

  /// Actualiza el estado de la lista.
  Future<List<T>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) {
    if (randomSeed != null) {
      return repository.getRandom(
        page: page,
        limit: limit,
        filter: filter,
        search: search,
        orderBy: orderBy,
        ascending: ascending,
        randomSeed: randomSeed,
        params: state.params,
      );
    } else {
      return repository.getPaginated(
        page: page,
        limit: limit,
        filter: filter,
        search: search,
        orderBy: orderBy,
        ascending: ascending,
        params: state.params,
      );
    }
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

  /// Agrega un elemento a la lista.
  Future<String?> add(T element) async {
    try {
      // Se invoca el método create del repositorio para insertar el elemento.
      final newId = await repository.create(element);
      if (newId != null) {
        // Actualiza el estado para reflejar el nuevo elemento (usando newElementId).
        emit(state.copyWith(newElementId: newId));
        // Refresca la paginación para que el nuevo elemento aparezca en la lista.
        refresh();
        return newId;
      }
    } catch (e) {
      // En caso de error, se actualiza el estado con el mensaje de error.
      emit(state.copyWith(errorMessage: e.toString()));
    }
    return null;
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
