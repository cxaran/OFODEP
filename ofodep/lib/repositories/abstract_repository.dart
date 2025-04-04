import 'package:ofodep/models/abstract_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Repository<T extends ModelComponent> {
  /// Nombre de la tabla en Supabase.
  String get tableName;

  /// Lista de columnas para busqueda textual.
  List<String> get searchColumns => ['name'];

  /// Lista de columnas para busqueda textual en listas.
  List<String> get arraySearchColumns => ['tags'];

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

  Future<dynamic> getValueById(
    String id,
    String column, {
    String? field,
  }) async {
    try {
      final data = await client
          .from(tableName)
          .select(column)
          .eq(
            field ?? this.fieldId,
            id,
          )
          .maybeSingle();

      if (data == null) return null;
      return data[column];
    } catch (e) {
      throw Exception('error(getFieldById): $e');
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

  PostgrestFilterBuilder<List<Map<String, dynamic>>> getSearch({
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    List<String>? arraySearchColumns,
    String? orderBy,
    bool ascending = false,
    String? select,
  }) {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
          client.from(tableName).select(select ?? this.select);

      if (filter != null) {
        filter.forEach((k, v) {
          query = k.endsWith('#gte')
              ? query.gte(k.replaceAll('#gte', ''), v)
              : k.endsWith('#lte')
                  ? query.lte(k.replaceAll('#lte', ''), v)
                  : k.endsWith('#neq')
                      ? query.neq(k.replaceAll('#neq', ''), v)
                      : k.endsWith('#like')
                          ? query.ilike(k.replaceAll('#like', ''), v)
                          : k.endsWith('#contains')
                              ? query.contains(k.replaceAll('#contains', ''), v)
                              : query.eq(k, v);
        });
      }

      // Búsqueda textual flexible: se pueden especificar una o más columnas
      if (search != null && search.isNotEmpty) {
        final textColumns = searchColumns ?? this.searchColumns;
        final arrayColumns = arraySearchColumns ?? this.arraySearchColumns;

        final textFilter =
            textColumns.map((col) => "$col.ilike.%$search%").join(',');
        final arrayFilter =
            arrayColumns.map((col) => "$col.cs.{$search}").join(',');

        // Combina ambas condiciones OR en una sola cadena.
        final combinedFilter = '$textFilter,$arrayFilter';
        query = query.or(combinedFilter);
      }

      return query;
    } catch (e) {
      throw Exception('error(getSearch): $e');
    }
  }

  /// Obtiene una lista paginada de modelos con opciones de filtrado y ordenamiento.
  /// [page] número de página (empezando en 1).
  /// [limit] cantidad de registros por página.
  /// [filter] mapa de filtros aplicables (como fechas o flags).
  /// [search] texto a buscar en los campos.
  /// [searchColumns] lista de columnas a buscar en el texto.
  /// [arraySearchColumns] lista de columnas de tipo array a buscar en el texto.
  /// [orderBy] campo por el cual se ordena (ej: 'created_at').
  /// [ascending] orden ascendente si es true, descendente si es false.
  Future<List<T>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    List<String>? arraySearchColumns,
    String? orderBy,
    bool ascending = false,
    String? select,
  }) async {
    try {
      // Búsqueda y filtros
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = getSearch(
        filter: filter,
        search: search,
        searchColumns: searchColumns,
        arraySearchColumns: arraySearchColumns,
        select: select,
      );

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

  /// Obtiene una lista de modelos de forma aleatoria.
  /// [page] número de página (empezando en 1).
  /// [limit] cantidad de registros por página.
  /// [filter] mapa de filtros aplicables (como fechas o flags).
  /// [search] texto a buscar en los campos.
  /// [searchColumns] lista de columnas a buscar en el texto.
  /// [arraySearchColumns] lista de columnas de tipo array a buscar en el texto.
  /// [randomSeed] semilla para generar un orden aleatorio pero consistente.
  /// [select] campos a seleccionar.
  Future<List<T>> getRandom({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    List<String>? arraySearchColumns,
    String? randomSeed,
    String? orderBy,
    bool ascending = false,
    String? select,
  }) async {
    try {
      // Búsqueda y filtros
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = getSearch(
        filter: filter,
        search: search,
        searchColumns: searchColumns,
        arraySearchColumns: arraySearchColumns,
        select: select,
      );

      // Se verifica que se haya pasado un 'randomSeed'. Si no, se asigna uno por defecto.
      if (randomSeed == null || randomSeed.isEmpty) {
        randomSeed = 'default_seed';
      }

      // Se genera la expresión para obtener un hash MD5 estable por cada registro.
      // La expresión "md5(id || '$randomSeed')" concatena el campo 'id' del registro con la semilla
      // y aplica md5 para generar un hash. Este hash se usará para ordenar de forma aleatoria pero
      // consistente mientras la semilla sea la misma.
      final randomExpr = "md5(id || '$randomSeed')";

      // Se aplica el ordenamiento usando la expresión generada.
      // 'ascending: true' ordena de forma ascendente por el hash.
      PostgrestTransformBuilder<List<Map<String, dynamic>>> paginationQuery =
          query.order(
        randomExpr,
        ascending: true,
      );

      // Ordenamiento
      if (orderBy != null && orderBy.isNotEmpty) {
        paginationQuery = query.order(orderBy, ascending: ascending);
      }

      // Se define el rango de resultados para la paginación.
      paginationQuery = paginationQuery.range(
        (page - 1) * limit,
        (page * limit) - 1,
      );

      final List<dynamic> response = await paginationQuery;
      return response
          .map<T>((data) => fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('error(getRandom): $e');
    }
  }
}
