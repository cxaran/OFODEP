import 'package:ofodep/models/abstract_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Repository<T extends ModelComponent> {
  /// Nombre de la tabla en Supabase.
  String get tableName;

  /// Lista de columnas para busqueda textual.
  List<String> get searchColumns => ['name'];

  /// Select from supabase.
  String get select => '*';

  /// Field id for get.
  String get fieldId => 'id';

  /// Función que convierte un Map en una instancia de [T].
  T fromMap(Map<String, dynamic> map);

  /// Cliente de Supabase (se usa la instancia global, aunque podría inyectarse).
  final SupabaseClient client = Supabase.instance.client;

  /// Obtiene una instancia del modelo por su ID único.
  /// [id] ID de la instancia a buscar.
  Future<T?> getById(
    String id, {
    String? select,
    String? field,
  }) async {
    try {
      final data = await client
          .from(tableName)
          .select(select ?? this.select)
          .eq(
            field ?? this.fieldId,
            id,
          )
          .maybeSingle();

      if (data == null) return null;
      return fromMap(data);
    } catch (e) {
      throw Exception('error(getById): $e');
    }
  }

  /// Crea una nueva instancia del modelo en la base de datos Supabase.
  /// Retorna el ID generado por la base de datos (usualmente UUID).
  /// [model] instancia del modelo a insertar.
  Future<String?> create(T model) async {
    try {
      final response = await client
          .from(tableName)
          .insert(model.toMap(includeId: false))
          .select('id')
          .maybeSingle();

      if (response != null && response.containsKey('id')) {
        return response['id'] as String;
      }
      return null;
    } catch (e) {
      throw Exception('error(create): $e');
    }
  }

  /// Actualiza una instancia existente del modelo en la base de datos.
  /// Retorna true si la operación fue exitosa.
  /// [model] instancia del modelo con los campos modificados.
  Future<bool> update(T model) async {
    try {
      final response = await client
          .from(tableName)
          .update(model.toMap())
          .eq('id', model.id)
          .select('id');

      if (response.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('error(update): $e');
    }
  }

  Future<List<T>> find(String field, dynamic value) async {
    try {
      final response =
          await client.from(tableName).select(select).eq(field, value);
      return response.map((data) => fromMap(data)).toList();
    } catch (e) {
      throw Exception('error(getByFieldValue): $e');
    }
  }

  /// Elimina una instancia del modelo por su ID.
  /// Retorna true si la eliminación fue exitosa.
  /// [id] ID de la instancia a eliminar.
  Future<bool> delete(String id) async {
    try {
      final response =
          await client.from(tableName).delete().eq('id', id).select('id');

      if (response.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('error(delete): $e');
    }
  }

  /// Obtiene una lista paginada de modelos con opciones de filtrado y ordenamiento.
  /// [page] número de página (empezando en 1).
  /// [limit] cantidad de registros por página.
  /// [filter] mapa de filtros aplicables (como fechas o flags).
  /// [search] texto a buscar en los campos.
  /// [searchColumns] lista de columnas a buscar en.
  /// [orderBy] campo por el cual se ordena (ej: 'created_at').
  /// [ascending] orden ascendente si es true, descendente si es false.
  Future<List<T>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    String? orderBy,
    bool ascending = false,
    String? select,
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
          client.from(tableName).select(select ?? this.select);

      // Aplicar filtros personalizados
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

      // Búsqueda textual flexible: se pueden especificar una o más columnas
      if (search != null && search.isNotEmpty) {
        // Si no se provee, se utiliza 'name' por defecto.
        final columns = searchColumns ?? this.searchColumns;
        // Se genera una cadena de búsqueda OR: columna1.ilike.%valor%,columna2.ilike.%valor%,...
        final searchFilter =
            columns.map((col) => "$col.ilike.%$search%").join(',');
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
      return response
          .map<T>((data) => fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('error(getPaginated): $e');
    }
  }
}
