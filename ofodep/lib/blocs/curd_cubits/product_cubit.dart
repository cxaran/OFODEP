import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/repositories/product_configuration_repository.dart';
import 'package:ofodep/repositories/product_option_repository.dart';
import 'package:ofodep/repositories/product_repository.dart';

class ProductCrudLoaded extends CrudLoaded<ProductModel> {
  final List<ProductConfigurationModel> configurations;
  final List<ProductOptionModel> options;

  ProductCrudLoaded(
    super.model, {
    super.message,
    this.configurations = const [],
    this.options = const [],
  });

  @override
  ProductCrudLoaded copyWith({
    ProductModel? model,
    String? message,
    List<ProductConfigurationModel>? configurations,
    List<ProductOptionModel>? options,
  }) {
    return ProductCrudLoaded(
      model ?? this.model,
      message: message ?? this.message,
      configurations: configurations ?? this.configurations,
      options: options ?? this.options,
    );
  }
}

class ProductCrudEditing extends CrudEditing<ProductModel> {
  final List<ProductConfigurationModel> configurations;
  final List<ProductConfigurationModel> deletedConfigurations;
  final List<ProductOptionModel> options;
  final List<ProductOptionModel> deletedOptions;

  ProductCrudEditing({
    required super.model,
    super.editedModel,
    super.editMode,
    super.isSubmitting,
    super.errorMessage,
    required this.configurations,
    this.deletedConfigurations = const [],
    required this.options,
    this.deletedOptions = const [],
  });

  @override
  ProductCrudEditing copyWith({
    ProductModel? model,
    ProductModel? editedModel,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
    List<ProductConfigurationModel>? configurations,
    List<ProductConfigurationModel>? deletedConfigurations,
    List<ProductOptionModel>? options,
    List<ProductOptionModel>? deletedOptions,
  }) {
    return ProductCrudEditing(
      model: model ?? this.model,
      editedModel: editedModel ?? this.editedModel,
      editMode: editMode ?? this.editMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      configurations: configurations ?? this.configurations,
      deletedConfigurations:
          deletedConfigurations ?? this.deletedConfigurations,
      options: options ?? this.options,
      deletedOptions: deletedOptions ?? this.deletedOptions,
    );
  }
}

class ProductCrudCreate extends CrudCreate<ProductModel> {
  final List<ProductConfigurationModel> configurations;
  final List<ProductOptionModel> options;

  ProductCrudCreate({
    required super.editedModel,
    super.isSubmitting,
    super.errorMessage,
    this.configurations = const [],
    this.options = const [],
  });

  @override
  ProductCrudCreate copyWith({
    ProductModel? editedModel,
    bool? editMode,
    bool? isSubmitting,
    String? errorMessage,
    List<ProductConfigurationModel>? configurations,
    List<ProductOptionModel>? options,
  }) {
    return ProductCrudCreate(
      editedModel: editedModel ?? this.editedModel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      configurations: configurations ?? this.configurations,
      options: options ?? this.options,
    );
  }
}

class ProductCubit extends CrudCubit<ProductModel, ProductRepository> {
  ProductCubit({
    super.repository = const ProductRepository(),
    super.initialState,
  });

  @override
  Future<void> load(
    String? id, {
    ProductModel? model,
    ProductModel? createModel,
  }) async {
    await super.load(id, model: model, createModel: createModel);
    loadConfigurationsAndOptions();
  }

  @override
  void startEditing() {
    final current = state;
    if (current is ProductCrudLoaded) {
      emit(ProductCrudEditing(
        model: current.model,
        configurations: current.configurations,
        options: current.options,
      ));
    } else {
      super.startEditing();
    }
  }

  @override
  Future<void> delete() async {
    final current = state;
    if (current is ProductCrudLoaded) {
      emit(CrudLoading<ProductModel>());
      try {
        final success = await repository.delete(current.model.id);
        if (success) {
          await ProductConfigurationRepository().deleteByFieldValue(
            'product_id',
            current.model.id,
          );
          await ProductOptionRepository().deleteByFieldValue(
            'product_id',
            current.model.id,
          );
          emit(CrudDeleted<ProductModel>(current.model.id));
        } else {
          emit(CrudError<ProductModel>('error(delete)'));
        }
      } catch (e) {
        emit(CrudError<ProductModel>(e.toString()));
      }
    } else {
      super.delete();
    }
  }

  @override
  Future<void> submit({String? successMessage}) async {
    final current = state;
    if (current is ProductCrudEditing) {
      emit(current.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final success = await repository.update(current.editedModel);
        if (success) {
          if (current.configurations.isNotEmpty) {
            await ProductConfigurationRepository().upsert(current.configurations
                .map((e) =>
                    e.copyWith(position: current.configurations.indexOf(e)))
                .toList());
          }
          if (current.deletedConfigurations.isNotEmpty) {
            List<String> deletedIds =
                current.deletedConfigurations.map((e) => e.id).toList();
            await ProductConfigurationRepository().deleteByFieldInFilter(
              'id',
              deletedIds,
            );
          }
          if (current.options.isNotEmpty) {
            await ProductOptionRepository().upsert(current.options
                .map((e) => e.copyWith(position: current.options.indexOf(e)))
                .toList());
          }
          if (current.deletedOptions.isNotEmpty) {
            List<String> deletedIds =
                current.deletedOptions.map((e) => e.id).toList();
            await ProductOptionRepository().deleteByFieldInFilter(
              'id',
              deletedIds,
            );
          }
          emit(ProductCrudLoaded(
            current.editedModel,
            message: successMessage ?? '$ProductModel has been updated',
            configurations: current.configurations,
            options: current.options,
          ));
        } else {
          emit(current.copyWith(
              isSubmitting: false, errorMessage: 'error(submit)'));
        }
      } catch (e) {
        emit(current.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    } else {
      super.submit(successMessage: successMessage);
    }
  }

  @override
  Future<String?> create({String? successMessage}) async {
    final current = state;
    if (current is ProductCrudCreate) {
      emit(current.copyWith(isSubmitting: true, errorMessage: null));
      try {
        final createdId = await repository.create(current.editedModel);
        if (createdId != null) {
          if (current.configurations.isNotEmpty) {
            await ProductConfigurationRepository().upsert(current.configurations
                .map((e) =>
                    e.copyWith(position: current.configurations.indexOf(e)))
                .toList());
          }
          if (current.options.isNotEmpty) {
            await ProductOptionRepository().upsert(current.options
                .map((e) => e.copyWith(position: current.options.indexOf(e)))
                .toList());
          }
          emit(ProductCrudLoaded(
            current.editedModel.copyWith(id: createdId),
            message: successMessage ?? '$ProductModel has been created',
            configurations: current.configurations,
            options: current.options,
          ));
          return createdId;
        } else {
          emit(
            current.copyWith(
              isSubmitting: false,
              errorMessage: 'error(create)',
            ),
          );
        }
      } catch (e) {
        emit(current.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    } else {
      return super.create(successMessage: successMessage);
    }
    return null;
  }

  /// Cargar configuraciones y opciones
  Future<void> loadConfigurationsAndOptions() async {
    final current = state;
    if (current is CrudLoaded<ProductModel>) {
      try {
        final configurations = await ProductConfigurationRepository()
            .find('product_id', current.model.id);
        configurations.sort((a, b) => a.position!.compareTo(b.position!));
        final options = await ProductOptionRepository()
            .find('product_id', current.model.id);
        options.sort((a, b) => a.position!.compareTo(b.position!));
        emit(ProductCrudLoaded(
          current.model,
          configurations: configurations,
          options: options,
        ));
      } catch (e) {
        emit(current.copyWith(
          message: 'error(loadConfigurationsAndOptions)',
        ) as CrudLoaded<ProductModel>);
      }
    }
    if (current is CrudCreate<ProductModel>) {
      emit(ProductCrudCreate(
        editedModel: current.editedModel,
      ));
    }
  }

  /// Agregar una nueva configuración
  Future<void> addConfiguration(String name) async {
    if (state is ProductCrudEditing || state is ProductCrudCreate) {
      final concreteState = state as dynamic;
      emit(
        concreteState.copyWith(
          configurations: List<ProductConfigurationModel>.from([
            ...concreteState.configurations,
            ProductConfigurationModel(
              storeId: concreteState.editedModel.storeId,
              productId: concreteState.editedModel.id,
              name: name,
              position: concreteState.configurations.length,
              updatedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ]),
        ),
      );
    }
  }

  /// Agregar una nueva opción
  Future<void> addOption(String name, String configurationId) async {
    if (state is ProductCrudEditing || state is ProductCrudCreate) {
      final concreteState = state as dynamic;
      emit(
        concreteState.copyWith(
          options: List<ProductOptionModel>.from([
            ...concreteState.options,
            ProductOptionModel(
              storeId: concreteState.editedModel.storeId,
              productId: concreteState.editedModel.id,
              configurationId: configurationId,
              name: name,
              extraPrice: 0,
              rangeMin: 0,
              rangeMax: 1,
              position: concreteState.options.length,
              updatedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ]),
        ),
      );
    }
  }

  /// Eliminar una configuración
  Future<void> deleteConfiguration(String configurationId) async {
    if (state is ProductCrudEditing) {
      final concreteState = state as dynamic;
      emit(
        concreteState.copyWith(
          deletedConfigurations: List<ProductConfigurationModel>.from([
            ...concreteState.deletedConfigurations,
            concreteState.configurations.firstWhere(
              (element) => element.id == configurationId,
            ),
          ]),
          configurations: List<ProductConfigurationModel>.from([
            ...concreteState.configurations.where(
              (element) => element.id != configurationId,
            ),
          ]),
        ),
      );
    }
    if (state is ProductCrudCreate) {
      final concreteState = state as dynamic;
      emit(
        concreteState.copyWith(
          configurations: List<ProductConfigurationModel>.from([
            ...concreteState.configurations.where(
              (element) => element.id != configurationId,
            ),
          ]),
        ),
      );
    }
  }

  /// Eliminar una opción
  Future<void> deleteOption(String optionId) async {
    if (state is ProductCrudEditing) {
      final concreteState = state as dynamic;
      emit(
        concreteState.copyWith(
          deletedOptions: List<ProductOptionModel>.from([
            ...concreteState.deletedOptions,
            concreteState.options.firstWhere(
              (element) => element.id == optionId,
            ),
          ]),
          options: List<ProductOptionModel>.from([
            ...concreteState.options.where(
              (element) => element.id != optionId,
            ),
          ]),
        ),
      );
    }
    if (state is ProductCrudCreate) {
      final concreteState = state as dynamic;
      emit(
        concreteState.copyWith(
          options: List<ProductOptionModel>.from([
            ...concreteState.options.where(
              (element) => element.id != optionId,
            ),
          ]),
        ),
      );
    }
  }

  /// Actualizar una configuración
  Future<void> updateConfiguration(
    String configurationId, {
    String? name,
    String? description,
    int? rangeMin,
    int? rangeMax,
  }) async {
    if (state is ProductCrudEditing || state is ProductCrudCreate) {
      final concreteState = state as dynamic;
      final configurations = List<ProductConfigurationModel>.from(
        concreteState.configurations,
      );
      int index = configurations.indexWhere(
        (element) => element.id == configurationId,
      );
      if (index != -1) {
        configurations[index] = configurations[index].copyWith(
          name: name,
          description: description ?? configurations[index].description,
          rangeMin: rangeMin ?? configurations[index].rangeMin,
          rangeMax: rangeMax ?? configurations[index].rangeMax,
        );
      }
      emit(
        concreteState.copyWith(
          editMode: true,
          configurations: configurations,
        ),
      );
    }
  }

  /// Actualizar una opción
  Future<void> updateOption(
    String optionId, {
    String? name,
    int? rangeMin,
    int? rangeMax,
    num? extraPrice,
  }) async {
    if (state is ProductCrudEditing || state is ProductCrudCreate) {
      final concreteState = state as dynamic;
      final options = List<ProductOptionModel>.from(concreteState.options);
      int index = options.indexWhere(
        (element) => element.id == optionId,
      );
      if (index != -1) {
        options[index] = options[index].copyWith(
          name: name ?? options[index].name,
          rangeMin: rangeMin ?? options[index].rangeMin,
          rangeMax: rangeMax ?? options[index].rangeMax,
          extraPrice: extraPrice ?? options[index].extraPrice,
        );
      }
      emit(
        concreteState.copyWith(
          editMode: true,
          options: options,
        ),
      );
    }
  }
}
