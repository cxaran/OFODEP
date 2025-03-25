import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/product_configuration_repository.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class ProductRepository extends Repository<ProductModel> {
  @override
  String get tableName => 'products';

  @override
  List<String> searchColumns = ['name', 'description', 'tags'];

  // Se utiliza el cliente heredado de Repository (client)
  final ProductConfigurationRepository configurationRepository =
      ProductConfigurationRepository();

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);

  /// Sobrescribe getById para incluir la relación con stores y cargar las configuraciones del producto.
  @override
  Future<ProductModel?> getById(
    String id, {
    String select = '*, stores(name)',
    String field = 'id',
  }) async =>
      super.getById(
        id,
      );

  /// Obtiene una lista paginada de productos, con la posibilidad de filtrar por store y búsqueda textual
  /// - [storeId]: Filtra los productos que pertenecen a una tienda específica.
  /// - [configurations]: Si es true, se cargarán las configuraciones de cada producto.
  @override
  Future<List<ProductModel>> getPaginated({
    String? storeId,
    bool configurations = false,
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    String? orderBy,
    bool ascending = false,
    String select = '*, stores(name)',
  }) =>
      super.getPaginated(
        page: page,
        limit: limit,
        filter: filter,
        search: search,
        searchColumns: searchColumns,
        orderBy: orderBy,
        ascending: ascending,
        select: select,
      );
}
