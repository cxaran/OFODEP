import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/models/filter_state.dart';
import 'package:ofodep/models/usuario.dart';
import 'package:ofodep/repositories/user_repository.dart';

/// Estado que almacena los filtros y configuraciones de ordenado.
class UsersListFilterState extends ListFilterState {
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
    bool? randomOrder,
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
  late final PagingController<int, Usuario> pagingController;
  int limit;

  UsersListCubit({
    UserRepository? userRepository,
    this.limit = 10,
  }) : super(UsersListFilterState()) {
    _userRepository = userRepository ?? UserRepository();
    pagingController = PagingController<int, Usuario>(
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

  // Métodos para actualizar filtros, búsqueda y ordenado.
  void updateSearch(String? search) {
    emit(state.copyWith(search: search));
    pagingController.refresh();
  }

  void updateFilter(Map<String, dynamic>? filter) {
    emit(state.copyWith(filter: filter));
    pagingController.refresh();
  }

  void updateOrdering({String? orderBy, bool? ascending, bool? randomOrder}) {
    emit(state.copyWith(
      orderBy: orderBy,
      ascending: ascending,
      randomOrder: randomOrder,
    ));
    pagingController.refresh();
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
