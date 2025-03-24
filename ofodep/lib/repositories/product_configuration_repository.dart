import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductConfigurationRepository
    extends Repository<ProductConfigurationModel> {
  @override
  String get tableName => 'product_configurations';

  @override
  ProductConfigurationModel fromMap(Map<String, dynamic> map) {
    return ProductConfigurationModel.fromMap(map);
  }

  /// Obtiene una lista de configuraciones para un producto específico.
  /// [productId] es el ID del producto cuyos configurations se desean obtener.
  Future<List<ProductConfigurationModel>> getByProductId(
      String productId) async {
    try {
      final response =
          await client.from(tableName).select('*').eq('product_id', productId);
      return response.map((data) => fromMap(data)).toList();
    } catch (e) {
      throw Exception('error(getByProductId): $e');
    }
  }
}
