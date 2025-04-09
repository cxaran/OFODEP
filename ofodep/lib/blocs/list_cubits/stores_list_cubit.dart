import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/enums.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/repositories/store_repository.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/repositories/store_subscription_repository.dart';

class StoresListCubit extends ListCubit<StoreModel> {
  StoresListCubit({StoreRepository? storeRepository, super.limit})
      : super(
          initialState: const FilterState(),
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
    Map<String, dynamic>? geom,
    String? whatsapp,
    num? deliveryMinimumOrder,
    bool pickup = false,
    bool delivery = false,
    num? deliveryPrice,
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
      geom: geom,
      whatsapp: whatsapp,
      deliveryMinimumOrder: deliveryMinimumOrder,
      pickup: pickup,
      delivery: delivery,
      deliveryPrice: deliveryPrice,
    );
    try {
      // Se invoca el método create del repositorio para insertar el elemento.
      final newStoreId = await repository.create(newStore);
      if (newStoreId != null) {
        // Crear la suscripción de la tienda.
        final newStoreSubscriptionId =
            await StoreSubscriptionRepository().create(
          StoreSubscriptionModel(
            id: '',
            storeId: newStoreId,
            storeName: name,
            subscriptionType: SubscriptionType.general,
            expirationDate: DateTime.now().subtract(
              const Duration(days: 1),
            ),
          ),
        );
        // Actualiza el estado para reflejar el nuevo elemento (usando newElementId).
        if (newStoreSubscriptionId != null) {
          // Emitir el error de la creación de la suscripción.
          emit(
            state.copyWith(
              newElementId: newStoreId,
              errorMessage: 'error(store_subscription)',
            ),
          );
        } else {
          emit(state.copyWith(newElementId: newStoreId));
        }

        // Refresca la paginación para que el nuevo elemento aparezca en la lista.
        refresh();
      }
    } catch (e) {
      // En caso de error, se actualiza el estado con el mensaje de error.
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
