import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/models/filter_state.dart';
import 'package:ofodep/models/zona.dart';
import 'package:ofodep/repositories/zone_repository.dart';

/// Estado que almacena filtros, búsqueda y configuración de ordenamiento para zonas.
class ZonesListFilterState extends ListFilterState {
  const ZonesListFilterState({
    super.filter,
    super.search,
    super.orderBy,
    super.ascending,
    super.errorMessage,
  });

  @override
  ZonesListFilterState copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
  }) {
    return ZonesListFilterState(
      filter: filter ?? this.filter,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Cubit que administra la lógica de paginación y filtros para zonas,
/// utilizando el PagingController de infinite_scroll_pagination.
class ZonesListCubit extends Cubit<ZonesListFilterState> {
  late final ZoneRepository _zoneRepository;
  late final PagingController<int, Zona> pagingController;
  int limit;

  ZonesListCubit({
    ZoneRepository? zoneRepository,
    this.limit = 10,
  }) : super(ZonesListFilterState()) {
    _zoneRepository = zoneRepository ?? ZoneRepository();
    pagingController = PagingController<int, Zona>(
      getNextPageKey: (state) {
        // Obtiene la última página y la incrementa.
        final currentPage = state.keys?.last ?? 0;
        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        try {
          final newZones = await _zoneRepository.getZones(
            page: pageKey,
            limit: limit,
            filter: state.filter,
            search: state.search,
            orderBy: state.orderBy,
            ascending: state.ascending,
          );

          if (newZones.isEmpty) {
            pagingController.value =
                pagingController.value.copyWith(hasNextPage: false);
          }
          return newZones;
        } on Exception catch (e) {
          emit(state.copyWith(errorMessage: e.toString()));
          pagingController.value =
              pagingController.value.copyWith(hasNextPage: false);
          return [];
        }
      },
    );
  }

  // Actualiza la búsqueda.
  void updateSearch(String? search) {
    emit(state.copyWith(search: search));
    pagingController.refresh();
  }

  // Actualiza los filtros.
  void updateFilter(Map<String, dynamic>? filter) {
    emit(state.copyWith(filter: filter));
    pagingController.refresh();
  }

  // Actualiza el ordenamiento.
  void updateOrdering({String? orderBy, bool? ascending}) {
    emit(state.copyWith(
      orderBy: orderBy,
      ascending: ascending,
    ));
    pagingController.refresh();
  }

  /// Método para agregar una zona (solo con nombre)
  Future<void> addZone(String zoneName) async {
    try {
      final newZone = await _zoneRepository.createZone(
        nombre: zoneName,
      );
      if (newZone != null) {
        // Se refresca la lista para que se muestre la nueva zona, si corresponde.
        pagingController.refresh();
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
