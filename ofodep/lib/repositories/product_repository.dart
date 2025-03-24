import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/product_configuration_repository.dart';
import 'package:ofodep/repositories/abstract_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository extends Repository<ProductModel> {
  @override
  String get tableName => 'products';

  // Se utiliza el cliente heredado de Repository (client)
  final ProductConfigurationRepository configurationRepository =
      ProductConfigurationRepository();

  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel.fromMap(map);
  }

  /// Sobrescribe getById para incluir la relación con stores y cargar las configuraciones del producto.
  @override
  Future<ProductModel?> getById(String id) async {
    try {
      final data = await client
          .from(tableName)
          .select('*, stores(name)')
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;

      final product = ProductModel.fromMap(data);
      // Se cargan las configuraciones relacionadas.
      product.configurations =
          await configurationRepository.getByProductId(product.id);
      return product;
    } catch (e) {
      throw Exception('error(getById): $e');
    }
  }

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
  }) async {
    try {
      // Se realiza la consulta incluyendo la relación con la tabla stores.
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
          client.from(tableName).select('*, stores(name)');

      // Filtrar por store si se especifica.
      if (storeId != null) {
        query = query.eq('store_id', storeId);
      }

      // Aplicar filtros personalizados.
      if (filter != null) {
        filter.forEach((filterKey, value) {
          if (filterKey.endsWith('_gte')) {
            query =
                query.gte(filterKey.substring(0, filterKey.length - 4), value);
          } else if (filterKey.endsWith('_lte')) {
            query =
                query.lte(filterKey.substring(0, filterKey.length - 4), value);
          } else {
            query = query.eq(filterKey, value);
          }
        });
      }

      // Búsqueda textual flexible.
      if (search != null && search.isNotEmpty) {
        // Para productos, se buscan en 'name' y en 'tags'.
        final columns = searchColumns ?? ['name', 'tags'];
        final searchFilter = columns.map((col) {
          // Si se busca en 'tags', se utiliza el operador de contención (cs).
          return col == 'tags' ? "$col.cs.{$search}" : "$col.ilike.%$search%";
        }).join(',');
        query = query.or(searchFilter);
      }

      PostgrestTransformBuilder<List<Map<String, dynamic>>> paginationQuery;

      // Ordenamiento
      if (orderBy != null && orderBy.isNotEmpty) {
        paginationQuery = query.order(orderBy, ascending: ascending);
      } else {
        paginationQuery = query.order('created_at', ascending: false);
      }

      // Paginación
      paginationQuery = paginationQuery.range(
        (page - 1) * limit,
        (page * limit) - 1,
      );

      final List<dynamic> response = await paginationQuery;
      final List<ProductModel> products = [];

      for (final item in response) {
        final product = ProductModel.fromMap(item as Map<String, dynamic>);
        if (configurations) {
          product.configurations = await configurationRepository.getByProductId(
            product.id,
          );
        }
        products.add(product);
      }

      return products;
    } catch (e) {
      throw Exception('error(getPaginated): $e');
    }
  }
}
