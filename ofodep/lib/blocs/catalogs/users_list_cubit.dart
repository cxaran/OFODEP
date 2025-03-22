import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/models/filter_state.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';

/// Estado que almacena los filtros y configuraciones de ordenado.
class UsersListFilterState extends ListFilterState {
  /// Crea un estado de filtros para usuarios.
  /// [filter] mapa de filtros
  /// [search] búsqueda textual
  /// [orderBy] campo por el que se ordena
  /// [ascending] orden ascendente
  /// [errorMessage] mensaje de error
  UsersListFilterState({
    super.filter,
    super.search,
    super.orderBy,
    super.ascending,
    super.errorMessage,
  });

  @override
  UsersListFilterState copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
  }) {
    return UsersListFilterState(
      filter: filter ?? this.filter,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Cubit que administra la lógica de paginación y filtros de usuarios,
/// utilizando el PagingController de infinite_scroll_pagination.
class UsersListCubit extends Cubit<UsersListFilterState> {
  late final UserRepository _userRepository;
  late final PagingController<int, UserModel> pagingController;
  int limit;

  /// Crea un Cubit que administra la lógica de paginación y filtros para usuarios,
  /// utilizando el PagingController de infinite_scroll_pagination.
  /// [userRepository] repositorio de usuarios
  /// [limit] número de registros por página
  UsersListCubit({
    UserRepository? userRepository,
    this.limit = 10,
  }) : super(UsersListFilterState()) {
    _userRepository = userRepository ?? UserRepository();
    pagingController = PagingController<int, UserModel>(
      getNextPageKey: (state) {
        final currentPage = state.keys?.last ?? 0;

        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        try {
          final newUsers = await _userRepository.getUsers(
            page: pageKey,
            limit: limit,
            filter: state.filter,
            search: state.search,
            orderBy: state.orderBy,
            ascending: state.ascending,
          );

          if (newUsers.isEmpty) {
            pagingController.value =
                pagingController.value.copyWith(hasNextPage: false);
          }
          return newUsers;
        } on Exception catch (e) {
          emit(state.copyWith(errorMessage: e.toString()));
          pagingController.value =
              pagingController.value.copyWith(hasNextPage: false);
          return [];
        }
      },
    );
  }

  /// Actualiza la búsqueda [search].
  void updateSearch(String? search) {
    emit(state.copyWith(search: search));
    pagingController.refresh();
  }

  /// Actualiza los filtros [filter].
  void updateFilter(Map<String, dynamic>? filter) {
    emit(state.copyWith(filter: filter));
    pagingController.refresh();
  }

  /// Actualiza el ordenamiento [orderBy] y [ascending].
  void updateOrdering({String? orderBy, bool? ascending}) {
    emit(state.copyWith(
      orderBy: orderBy,
      ascending: ascending,
    ));
    pagingController.refresh();
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
