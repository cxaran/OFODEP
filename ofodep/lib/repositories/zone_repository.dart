import 'package:ofodep/models/zona.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ZoneRepository {
  ZoneRepository();

  /// Obtiene una zona por su id.
  Future<Zona?> getZone(String zoneId) async {
    try {
      final data = await Supabase.instance.client
          .from('zonas')
          .select()
          .eq('id', zoneId)
          .maybeSingle();

      if (data == null) return null;
      return Zona.fromMap(data);
    } catch (e) {
      throw Exception('Error al obtener zona: $e');
    }
  }

  /// Actualiza el nombre y/o descripción de la zona.
  Future<bool> updateZone(
    String zoneId, {
    String? nombre,
    String? descripcion,
    Map<String, dynamic>? geom,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (nombre != null) updates['nombre'] = nombre;
      if (descripcion != null) updates['descripcion'] = descripcion;
      if (geom != null) updates['geom'] = geom;

      final response = await Supabase.instance.client
          .from('zonas')
          .update(updates)
          .eq('id', zoneId)
          .select('id');

      if (response.isEmpty) return false;
      return true;
    } on Exception catch (e) {
      throw Exception('Error al actualizar zona: $e');
    }
  }

  /// Agrega una nueva zona.
  Future<Zona?> createZone({
    required String nombre,
    String? descripcion,
    String? geom,
    List<String>? codigosPostales,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('zonas')
          .insert({
            'nombre': nombre,
            'descripcion': descripcion,
            'geom': geom,
            'codigos_postales': codigosPostales,
          })
          .select('id')
          .maybeSingle();

      if (response == null) return null;

      return Zona.fromMap(response);
    } catch (e) {
      throw Exception('Error al agregar zona: $e');
    }
  }

  /// Obtiene una lista paginada de zonas con filtros, búsqueda y ordenamiento.
  Future<List<Zona>> getZones({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) async {
    final supabase = Supabase.instance.client;

    // Construir la consulta básica.
    var query = supabase.from('zonas').select('*');

    // Aplicar filtros personalizados.
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
    }

    // Aplicar búsqueda textual (en nombre y descripción).
    if (search != null && search.isNotEmpty) {
      query = query.or('nombre.ilike.%$search%,descripcion.ilike.%$search%');
    }

    // Ordenamiento.
    var paginationQuery = (orderBy != null && orderBy.isNotEmpty)
        ? query.order(orderBy, ascending: ascending)
        : query.order('created_at', ascending: false);

    // Paginación.
    paginationQuery = paginationQuery.range(
      (page - 1) * limit,
      (page * limit) - 1,
    );

    try {
      // Ejecutar la consulta.
      final List<dynamic> response = await paginationQuery;
      // Convertir cada registro en una instancia de Zona.
      return response.map((data) => Zona.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error al obtener zonas: $e');
    }
  }
}
