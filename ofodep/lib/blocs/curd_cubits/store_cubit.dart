import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/store_repository.dart';

/// Secciones editables para la tienda.
enum StoreEditSection {
  general('general'),
  contact('contact'),
  coordinates('coordinates'),
  geom('geom'),
  delivery('delivery');

  const StoreEditSection(this.description);
  final String description;
}

/// Estado de edición especializado para StoreModel, que extiende del CrudEditing genérico
/// y añade la propiedad editSection.
class StoreCrudEditing extends CrudEditing<StoreModel> {
  final StoreEditSection editSection;

  StoreCrudEditing({
    required super.model,
    super.editedModel,
    required this.editSection,
    super.editMode,
    super.isSubmitting,
    super.errorMessage,
  });

  @override
  StoreCrudEditing copyWith({
    StoreModel? model,
    StoreModel? editedModel,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
    StoreEditSection? editSection,
  }) {
    return StoreCrudEditing(
      model: model ?? this.model,
      editedModel: editedModel ?? this.editedModel,
      editMode: editMode ?? this.editMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      editSection: editSection ?? this.editSection,
    );
  }
}

/// Cubit para manejar operaciones CRUD de StoreModel utilizando la abstracción CrudCubit.
/// Se utiliza el id de la tienda (storeId) pasado en el constructor y se mantiene la edición
/// por secciones mediante StoreCrudEditing.
class StoreCubit extends CrudCubit<StoreModel, StoreRepository> {
  StoreCubit({
    super.repository = const StoreRepository(),
    super.initialState,
  });

  /// Inicia el modo de edición, creando un estado que contiene el modelo original y una copia editable.
  @override
  void startEditing({StoreEditSection? editSection}) {
    if (editSection != null) {
      final current = state;
      if (current is CrudLoaded<StoreModel>) {
        emit(StoreCrudEditing(model: current.model, editSection: editSection));
      }
    }
  }
}
