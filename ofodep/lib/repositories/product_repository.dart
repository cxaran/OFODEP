import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ofodep/models/product_model.dart';

class ProductRepository {
  static const String tableName = 'products';
  static const String tableNameConfigurations = 'product_configurations';
  static const String tableNameOptions = 'product_options';

  final supabase = Supabase.instance.client;

  /// Obtiene un producto por ID incluyendo store_name y listas anidadas
  /// [productId] ID del producto
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final data = await supabase
          .from(tableName)
          .select('*, stores(name)')
          .eq('id', productId)
          .maybeSingle();

      if (data == null) return null;

      final product = ProductModel.fromMap(data);

      // Obtener configuraciones
      final configurations = await _getConfigurations(product.id);
      product.configurations = configurations;

      return product;
    } catch (e) {
      throw Exception('Error al obtener el producto: $e');
    }
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final response = await supabase
          .from(tableName)
          .insert(product.toMap())
          .select('id')
          .single();
      return response['id'] as String;
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  Future<bool> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    try {
      final response = await supabase
          .from(tableName)
          .update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId)
          .select('id');

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  /// Obtiene una lista paginada de productos con nombre de tienda
  /// [storeId] ID de la tienda
  /// [configurations] indica si se deben obtener las configuraciones
  /// [page] número de página (1-indexado)
  /// [limit] número de registros por página
  /// [filter] mapa opcional de filtros (ej: fechas, flag admin)
  /// [search] búsqueda textual (por nombre, email o teléfono)
  /// [orderBy] campo por el que se ordena (ej: 'created_at', 'name', 'email')
  /// [ascending] orden ascendente (true) o descendente (false)
  Future<List<ProductModel>> getProductsPaginated({
    String? storeId,
    bool configurations = false,
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) async {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        supabase.from(tableName).select('*, stores(name)');

    if (storeId != null) {
      query = query.eq('store_id', storeId);
    }

    // Aplicar filtros personalizados
    if (filter != null) {
      if (filter.containsKey('created_at_gte')) {
        query = query.gte('created_at', filter['created_at_gte']);
      }
      if (filter.containsKey('created_at_lte')) {
        query = query.lte('created_at', filter['created_at_lte']);
      }
      if (filter.containsKey('updated_at_gte')) {
        query = query.gte('updated_at', filter['updated_at_gte']);
      }
      if (filter.containsKey('updated_at_lte')) {
        query = query.lte('updated_at', filter['updated_at_lte']);
      }
      if (filter.containsKey('admin')) {
        query = query.eq('admin', filter['admin']);
      }
    }

    // Aplicar búsqueda textual (en name y lista de tags)
    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,tags.cs.{$search}');
    }

    PostgrestTransformBuilder<List<Map<String, dynamic>>> paginationQuery;

    // Aplicar ordenamiento
    if (orderBy != null && orderBy.isNotEmpty) {
      paginationQuery = query.order(orderBy, ascending: ascending);
    } else {
      // Orden por defecto: fecha de creación descendente
      paginationQuery = query.order('created_at', ascending: false);
    }

    // Aplicar paginación
    paginationQuery = paginationQuery.range(
      (page - 1) * limit,
      (page * limit) - 1,
    );

    try {
      // Ejecutar la consulta
      final List<dynamic> response = await paginationQuery;

      // Procesar datos y devolver la lista de productos
      final List<ProductModel> products = [];

      for (final item in response) {
        final product = ProductModel.fromMap(item);

        // Obtener configuraciones
        if (configurations) {
          product.configurations = await _getConfigurations(product.id);
        }

        products.add(product);
      }

      return products;
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  /// Internamente obtiene configuraciones y sus opciones
  Future<List<ProductConfigurationModel>> getConfigurations(
      String productId) async {
    try {
      final data = await supabase
          .from('product_configurations')
          .select()
          .eq('product_id', productId);

      final configurations = <ProductConfigurationModel>[];

      for (final conf in data) {
        final config = ProductConfigurationModel.fromMap(conf);
        config.options = await _getOptions(config.id);
        configurations.add(config);
      }

      return configurations;
    } catch (e) {
      throw Exception('Error al obtener configuraciones: $e');
    }
  }

  Future<List<ProductOptionModel>> _getOptions(String configurationId) async {
    try {
      final data = await supabase
          .from(tableNameOptions)
          .select()
          .eq('configuration_id', configurationId);

      return (data as List)
          .map((item) => ProductOptionModel.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener opciones: $e');
    }
  }
}
