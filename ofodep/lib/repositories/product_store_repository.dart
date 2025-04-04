import 'package:ofodep/models/product_store_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductStoreRepository extends Repository<ProductStoreModel> {
  @override
  String get tableName => 'products';

  @override
  List<String> searchColumns = ['name', 'description', 'tags'];

  /// La cláusula SELECT se define para:
  /// - Incluir todos los campos de productos.
  /// - Realizar un INNER JOIN con "stores" (alias "store") para traer los datos de la tienda.
  /// - Calcular "is_open" como columna computada, evaluando primero las excepciones
  ///   y, en su defecto, los horarios regulares.
  @override
  String get select => """
    *,
    stores!inner(
      name,
      logo_url,
      address_street,
      address_number,
      address_colony,
      address_zipcode,
      address_city,
      address_state,
      country_code,
      lat,
      lng,
      whatsapp,
      delivery_minimum_order,
      pickup,
      delivery,
      delivery_price,
      imgur_client_id,
      imgur_client_secret
    ),
    product_is_open
  """;

  @override
  ProductStoreModel fromMap(Map<String, dynamic> map) =>
      ProductStoreModel.fromMap(map);
}
