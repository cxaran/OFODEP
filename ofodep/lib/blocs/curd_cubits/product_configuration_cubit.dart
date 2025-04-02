import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/repositories/product_configuration_repository.dart';

class ProductConfigurationCubit extends CrudCubit<ProductConfigurationModel> {
  ProductConfigurationCubit({
    required super.id,
    ProductConfigurationRepository? productConfigurationRepository,
    CrudState<ProductConfigurationModel>? initialState,
  }) : super(
          initialState:
              initialState ?? CrudInitial<ProductConfigurationModel>(),
          repository: productConfigurationRepository ??
              ProductConfigurationRepository(),
        );
}
