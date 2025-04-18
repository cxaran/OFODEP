import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductConfigurationRepository
    extends Repository<ProductConfigurationModel> {
  const ProductConfigurationRepository();
  @override
  String get tableName => 'product_configurations';

  @override
  ProductConfigurationModel fromMap(Map<String, dynamic> map) =>
      ProductConfigurationModel.fromMap(map);
}
