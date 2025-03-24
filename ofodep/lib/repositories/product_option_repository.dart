import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductOptionRepository extends Repository<ProductOptionModel> {
  @override
  String get tableName => 'product_options';

  @override
  ProductOptionModel fromMap(Map<String, dynamic> map) {
    return ProductOptionModel.fromMap(map);
  }

  /// Obtiene una lista de opciones para una configuración de producto específica.
  /// [configurationId] es el ID de la configuración de la cual se desean obtener las opciones.
  Future<List<ProductOptionModel>> getByConfigurationId(
      String configurationId) async {
    try {
      final response = await client
          .from(tableName)
          .select('*')
          .eq('configuration_id', configurationId);
      return response.map((data) => fromMap(data)).toList();
    } catch (e) {
      throw Exception('error(getByConfigurationId): $e');
    }
  }
}
