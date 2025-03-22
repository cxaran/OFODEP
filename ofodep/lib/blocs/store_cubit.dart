import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/config/locations_strings.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/store_repository.dart';

/// Possible store states:
/// - [StoreInitial]: initial state.
/// - [StoreLoading]: loading state.
/// - [StoreLoaded]: loaded state with a [StoreModel].
/// - [StoreEditState]: edit state with editable data.
/// - [StoreError]: error state.
abstract class StoreState {}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

/// Loaded state, holding the [StoreModel].
class StoreLoaded extends StoreState {
  final StoreModel store;

  /// Creates the loaded state for a store.
  /// [store] the loaded store
  StoreLoaded(this.store);
}

enum StoreEditSection {
  general(StoreEditSectionGeneralTitle),
  contact(StoreEditSectionContactTitle),
  coordinates(StoreEditSectionCoordinatesTitle),
  codePostal(StoreEditSectionCodePostalTitle),
  delivery(StoreEditSectionDeliveryTitle),
  imageApi(StoreEditSectionImageApiTitle);

  const StoreEditSection(this.description);

  final String description;
}

/// Edit state that extends [StoreLoaded], allowing modifications.
class StoreEditState extends StoreLoaded {
  final String name;
  final String? logoUrl;
  final String? addressStreet;
  final String? addressNumber;
  final String? addressColony;
  final String? addressZipcode;
  final String? addressCity;
  final String? addressState;
  final num? lat;
  final num? lng;
  final List<String>? zipcodes;
  final String? whatsapp;
  final num? deliveryMinimumOrder;
  final bool pickup;
  final bool delivery;
  final num? deliveryPrice;
  final String? imgurClientId;
  final String? imgurClientSecret;
  final StoreEditSection editSection;
  final bool
      editMode; // Indicates whether any field has been edited, enabling the save button.
  final bool
      isSubmitting; // Indicates whether a submission (update) is in progress.
  final String? errorMessage;

  /// Constructor with all store fields.
  /// [name] Store name.
  /// [logoUrl] URL of the store logo.
  /// [addressStreet] Street in the address.
  /// [addressNumber] Number in the address.
  /// [addressColony] Neighborhood in the address.
  /// [addressZipcode] Zipcode in the address.
  /// [addressCity] City in the address.
  /// [addressState] State in the address.
  /// [lat] Geographical latitude.
  /// [lng] Geographical longitude.
  /// [zipcodes] List of additional zipcodes.
  /// [whatsapp] WhatsApp number of the store.
  /// [deliveryMinimumOrder] Minimum order amount for delivery.
  /// [pickup] Whether the store offers pickup service.
  /// [delivery] Whether the store offers delivery service.
  /// [deliveryPrice] Cost of the delivery service.
  /// [imgurClientId] Imgur client ID.
  /// [imgurClientSecret] Imgur client secret.
  /// [editSection] The currently edited section.
  /// [editMode] Whether there have been modifications (enables the save button).
  /// [isSubmitting] Whether the update request is being submitted.
  /// [errorMessage] Error message in case of failure.
  StoreEditState(
    super.store,
    this.editSection, {
    required this.name,
    this.logoUrl,
    this.addressStreet,
    this.addressNumber,
    this.addressColony,
    this.addressZipcode,
    this.addressCity,
    this.addressState,
    this.lat,
    this.lng,
    this.zipcodes,
    this.whatsapp,
    this.deliveryMinimumOrder,
    this.pickup = false,
    this.delivery = false,
    this.deliveryPrice,
    this.imgurClientId,
    this.imgurClientSecret,
    this.editMode = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Creates the edit state from a [store] and an [editSection].
  factory StoreEditState.fromStore(
    StoreModel store,
    StoreEditSection editSection,
  ) {
    return StoreEditState(
      store,
      editSection,
      name: store.name,
      logoUrl: store.logoUrl,
      addressStreet: store.addressStreet,
      addressNumber: store.addressNumber,
      addressColony: store.addressColony,
      addressZipcode: store.addressZipcode,
      addressCity: store.addressCity,
      addressState: store.addressState,
      lat: store.lat,
      lng: store.lng,
      zipcodes: store.zipcodes,
      whatsapp: store.whatsapp,
      deliveryMinimumOrder: store.deliveryMinimumOrder,
      pickup: store.pickup,
      delivery: store.delivery,
      deliveryPrice: store.deliveryPrice,
      imgurClientId: store.imgurClientId,
      imgurClientSecret: store.imgurClientSecret,
      editMode: false,
      isSubmitting: false,
      errorMessage: null,
    );
  }

  /// Allows updating fields of the state without modifying the original.
  StoreEditState copyWith({
    String? name,
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
    bool? pickup,
    bool? delivery,
    num? deliveryPrice,
    String? imgurClientId,
    String? imgurClientSecret,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return StoreEditState(
      store,
      editSection,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressColony: addressColony ?? this.addressColony,
      addressZipcode: addressZipcode ?? this.addressZipcode,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      zipcodes: zipcodes ?? this.zipcodes,
      whatsapp: whatsapp ?? this.whatsapp,
      deliveryMinimumOrder: deliveryMinimumOrder ?? this.deliveryMinimumOrder,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      imgurClientId: imgurClientId ?? this.imgurClientId,
      imgurClientSecret: imgurClientSecret ?? this.imgurClientSecret,
      editMode: editMode ?? this.editMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

/// Error state, holding an error [message].
class StoreError extends StoreState {
  final String message;
  StoreError({required this.message});
}

/// Cubit for managing store states and operations.
class StoreCubit extends Cubit<StoreState> {
  final String storeId;
  final StoreRepository storeRepository;

  StoreCubit(this.storeId, {StoreRepository? storeRepository})
      : storeRepository = storeRepository ?? StoreRepository(),
        super(StoreInitial());

  /// Loads the store from the database.
  Future<void> loadStore() async {
    emit(StoreLoading());
    try {
      final store = await storeRepository.getStore(storeId);
      if (store != null) {
        emit(StoreLoaded(store));
      } else {
        emit(StoreError(message: "Store not found"));
      }
    } catch (e) {
      emit(StoreError(message: "Error loading store: $e"));
    }
  }

  /// Toggles between edit mode and loaded state.
  /// [editSection] indicates the currently edited section.
  void edit({StoreEditSection? editSection}) {
    final currentState = state;
    if (currentState is StoreEditState) {
      emit(StoreLoaded(currentState.store));
    }
    if (currentState is StoreLoaded && editSection != null) {
      emit(StoreEditState.fromStore(currentState.store, editSection));
    }
  }

  /// Updates fields in the current edit state (if applicable).
  void changed({
    String? name,
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
    bool? pickup,
    bool? delivery,
    num? deliveryPrice,
    String? imgurClientId,
    String? imgurClientSecret,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    final currentState = state;
    if (currentState is StoreEditState) {
      emit(currentState.copyWith(
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
        editMode: editMode,
        isSubmitting: isSubmitting,
        errorMessage: errorMessage,
        imgurClientId: imgurClientId,
        imgurClientSecret: imgurClientSecret,
      ));
    }
  }

  /// Submits the updated store data.
  /// Basic validation is done before sending the request.
  Future<void> submit() async {
    final currentState = state;
    if (currentState is StoreEditState) {
      // Basic validation: name and addressStreet must not be empty.
      if (currentState.name.trim().isEmpty) {
        emit(currentState.copyWith(errorMessage: "The name is required"));
        return;
      }
      if (currentState.addressStreet == null ||
          currentState.addressStreet!.trim().isEmpty) {
        emit(currentState.copyWith(errorMessage: "The street is required"));
        return;
      }
      emit(currentState.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final success = await storeRepository.updateStore(
          storeId,
          name: currentState.name,
          logoUrl: currentState.logoUrl,
          addressStreet: currentState.addressStreet,
          addressNumber: currentState.addressNumber,
          addressColony: currentState.addressColony,
          addressZipcode: currentState.addressZipcode,
          addressCity: currentState.addressCity,
          addressState: currentState.addressState,
          lat: currentState.lat,
          lng: currentState.lng,
          zipcodes: currentState.zipcodes,
          whatsapp: currentState.whatsapp,
          deliveryMinimumOrder: currentState.deliveryMinimumOrder,
          pickup: currentState.pickup,
          delivery: currentState.delivery,
          deliveryPrice: currentState.deliveryPrice,
          imgurClientId: currentState.imgurClientId,
          imgurClientSecret: currentState.imgurClientSecret,
        );
        if (success) {
          // Reload the store to refresh fields.
          loadStore();
        } else {
          emit(
            currentState.copyWith(
              isSubmitting: false,
              errorMessage: "Error updating the store",
            ),
          );
        }
      } catch (e) {
        emit(
          currentState.copyWith(
            isSubmitting: false,
            errorMessage: "Error: $e",
          ),
        );
      }
    }
  }
}
