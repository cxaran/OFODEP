import 'package:ofodep/blocs/catalogs/abstract_list_cubit.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/store_repository.dart';
import 'package:ofodep/blocs/catalogs/filter_state.dart';

class StoresListCubit extends ListCubit<StoreModel, BasicListFilterState> {
  StoresListCubit({StoreRepository? storeRepository, super.limit})
      : super(
          initialState: const BasicListFilterState(),
          repository: storeRepository ?? StoreRepository(),
        );

  /// Método para agregar una tienda.
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
    String? imgurClientId,
    String? imgurClientSecret,
  }) async {
    final newStore = StoreModel(
      id: '',
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
      imgurClientId: imgurClientId,
      imgurClientSecret: imgurClientSecret,
    );
    super.add(newStore);
  }
}
