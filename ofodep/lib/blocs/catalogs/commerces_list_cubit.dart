import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/models/filter_state.dart';
import 'package:ofodep/models/comercio.dart';
import 'package:ofodep/repositories/commerce_repository.dart';

/// Estado que almacena filtros, búsqueda y configuración de ordenamiento para comercios.
class CommercesListFilterState extends ListFilterState {
  const CommercesListFilterState({
    super.filter,
    super.search,
    super.orderBy,
    super.ascending,
    super.errorMessage,
  });

  @override
  CommercesListFilterState copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
  }) {
    return CommercesListFilterState(
      filter: filter ?? this.filter,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Cubit que administra la lógica de paginación y filtros para comercios,
/// utilizando el PagingController de infinite_scroll_pagination.
class CommercesListCubit extends Cubit<CommercesListFilterState> {
  late final CommerceRepository _commerceRepository;
  late final PagingController<int, Comercio> pagingController;
  int limit;

  CommercesListCubit({
    CommerceRepository? commerceRepository,
    this.limit = 10,
  }) : super(CommercesListFilterState()) {
    _commerceRepository = commerceRepository ?? CommerceRepository();
    pagingController = PagingController<int, Comercio>(
      getNextPageKey: (state) {
        // Obtiene la última página y la incrementa.
        final currentPage = state.keys?.last ?? 0;
        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        try {
          final newCommerces = await _commerceRepository.getCommerces(
            page: pageKey,
            limit: limit,
            filter: state.filter,
            search: state.search,
            orderBy: state.orderBy,
            ascending: state.ascending,
          );

          if (newCommerces.isEmpty) {
            pagingController.value =
                pagingController.value.copyWith(hasNextPage: false);
          }
          return newCommerces;
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

  /// Método para agregar un comercio.
  Future<void> addCommerce({
    required String nombre,
    String? logoUrl,
    String? direccionCalle,
    String? direccionNumero,
    String? direccionColonia,
    String? direccionCp,
    String? direccionCiudad,
    String? direccionEstado,
    num? lat,
    num? lng,
    List<String>? codigosPostales,
    String? whatsapp,
    num? minimoCompraDelivery,
    bool pickup = false,
    bool delivery = false,
    num? precioDelivery,
  }) async {
    try {
      final newCommerce = await _commerceRepository.createCommerce(
        nombre: nombre,
        logoUrl: logoUrl,
        direccionCalle: direccionCalle,
        direccionNumero: direccionNumero,
        direccionColonia: direccionColonia,
        direccionCp: direccionCp,
        direccionCiudad: direccionCiudad,
        direccionEstado: direccionEstado,
        lat: lat,
        lng: lng,
        codigosPostales: codigosPostales,
        whatsapp: whatsapp,
        minimoCompraDelivery: minimoCompraDelivery,
        pickup: pickup,
        delivery: delivery,
        precioDelivery: precioDelivery,
      );
      if (newCommerce != null) {
        // Se refresca la lista para que se muestre la nueva comercio, si corresponde.
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
