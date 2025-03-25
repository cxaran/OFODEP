import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductOptionRepository extends Repository<ProductOptionModel> {
  @override
  String get tableName => 'product_options';

  @override
  ProductOptionModel fromMap(Map<String, dynamic> map) {
    return ProductOptionModel.fromMap(map);
  }
}
