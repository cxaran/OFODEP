import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/models/filter_state.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/store_repository.dart';

/// State that stores filters, search, and sorting configuration for stores.
class StoresListFilterState extends ListFilterState {
  /// Creates a filter state for stores.
  /// [filter] map of filters
  /// [search] textual search
  /// [orderBy] field by which the data is sorted
  /// [ascending] ascending sort order
  /// [errorMessage] error message
  const StoresListFilterState({
    super.filter,
    super.search,
    super.orderBy,
    super.ascending,
    super.errorMessage,
  });

  @override
  StoresListFilterState copyWith({
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool? ascending,
    String? errorMessage,
  }) {
    return StoresListFilterState(
      filter: filter ?? this.filter,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Cubit that manages pagination and filters logic for stores,
/// using the PagingController from infinite_scroll_pagination.
class StoresListCubit extends Cubit<StoresListFilterState> {
  late final StoreRepository _storeRepository;
  late final PagingController<int, StoreModel> pagingController;
  int limit;

  /// Creates a Cubit that manages pagination and filters logic for stores,
  /// using the PagingController from infinite_scroll_pagination.
  /// [storeRepository] optional repository for stores
  /// [limit] number of records per page
  StoresListCubit({
    StoreRepository? storeRepository,
    this.limit = 10,
  }) : super(const StoresListFilterState()) {
    _storeRepository = storeRepository ?? StoreRepository();
    pagingController = PagingController<int, StoreModel>(
      getNextPageKey: (state) {
        // Retrieves the last page key and increments it.
        final currentPage = state.keys?.last ?? 0;
        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        try {
          final newStores = await _storeRepository.getStores(
            page: pageKey,
            limit: limit,
            filter: state.filter,
            search: state.search,
            orderBy: state.orderBy,
            ascending: state.ascending,
          );

          if (newStores.isEmpty) {
            pagingController.value =
                pagingController.value.copyWith(hasNextPage: false);
          }
          return newStores;
        } on Exception catch (e) {
          emit(state.copyWith(errorMessage: e.toString()));
          pagingController.value =
              pagingController.value.copyWith(hasNextPage: false);
          return [];
        }
      },
    );
  }

  // Updates the search term.
  void updateSearch(String? search) {
    emit(state.copyWith(search: search));
    pagingController.refresh();
  }

  // Updates the filters.
  void updateFilter(Map<String, dynamic>? filter) {
    emit(state.copyWith(filter: filter));
    pagingController.refresh();
  }

  // Updates the sorting configuration.
  void updateOrdering({String? orderBy, bool? ascending}) {
    emit(state.copyWith(
      orderBy: orderBy,
      ascending: ascending,
    ));
    pagingController.refresh();
  }

  /// Method to add a store.
  /// [name] store name
  /// [logoUrl] store logo URL
  /// [addressStreet] store's street
  /// [addressNumber] store's street number
  /// [addressColony] store's neighborhood
  /// [addressZipcode] store's zipcode
  /// [addressCity] store's city
  /// [addressState] store's state
  /// [lat] store's geographical latitude
  /// [lng] store's geographical longitude
  /// [zipcodes] list of additional zipcodes
  /// [whatsapp] store's WhatsApp number
  /// [deliveryMinimumOrder] minimum order amount for delivery
  /// [pickup] indicates if the store offers pickup service
  /// [delivery] indicates if the store offers delivery service
  /// [deliveryPrice] cost of the delivery service
  Future<void> addStore({
    required String name,
    String? logoUrl,
    String? addressStreet,
    String? addressNumber,
    String? addressColony,
    String? addressZipcode,
    String? addressCity,
    String? addressState,
    num? lat,
    num? lng,
    List<String>? zipcodes,
    String? whatsapp,
    num? deliveryMinimumOrder,
    bool pickup = false,
    bool delivery = false,
    num? deliveryPrice,
  }) async {
    try {
      final newStore = await _storeRepository.createStore(
        name: name,
        logoUrl: logoUrl,
        addressStreet: addressStreet,
        addressNumber: addressNumber,
        addressColony: addressColony,
        addressZipcode: addressZipcode,
        addressCity: addressCity,
        addressState: addressState,
        lat: lat,
        lng: lng,
        zipcodes: zipcodes,
        whatsapp: whatsapp,
        deliveryMinimumOrder: deliveryMinimumOrder,
        pickup: pickup,
        delivery: delivery,
        deliveryPrice: deliveryPrice,
      );
      if (newStore != null) {
        // Refreshes the list so the new store appears, if applicable.
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
