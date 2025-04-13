import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductRepository extends Repository<ProductModel> {
  const ProductRepository();
  @override
  String get tableName => 'products';

  @override
  String get select => '*, stores(name), products_categories(name)';

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);
}
