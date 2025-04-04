import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductRepository extends Repository<ProductModel> {
  @override
  String get tableName => 'products';

  @override
  List<String> searchColumns = ['name', 'description', 'tags'];

  @override
  String get select => '*, stores(name)';

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);
}
