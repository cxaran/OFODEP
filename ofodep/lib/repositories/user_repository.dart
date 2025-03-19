import 'package:ofodep/models/usuario.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  UserRepository();

  /// Obtiene el usuario desde la tabla 'usuarios' filtrando por el auth_id.
  Future<Usuario?> getUser(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('auth_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return Usuario.fromMap(data);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Actualiza el nombre del usuario en la tabla 'usuarios'
  Future<bool> updateUserName(String userId, String newName) async {
    try {
      final response = await Supabase.instance.client
          .from('usuarios')
          .update({'nombre': newName}).eq('auth_id', userId);

      return response.error == null;
    } on Exception catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  /// Actualiza el teléfono del usuario en la tabla 'usuarios'
  Future<bool> updateUserPhone(String userId, String newPhone) async {
    try {
      final response = await Supabase.instance.client
          .from('usuarios')
          .update({'telefono': newPhone}).eq('auth_id', userId);

      return response.error == null;
    } on Exception catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  /// Obtiene una lista paginada de usuarios con opciones de filtrado y ordenado.
  /// [page] número de página (1-indexado)
  /// [limit] número de registros por página
  /// [filter] mapa opcional de filtros (e.g. fechas, flag admin)
  /// [search] búsqueda textual (por nombre, email o teléfono)
  /// [orderBy] campo por el que se ordena (ej: 'created_at', 'nombre', 'email')
  /// [ascending] orden ascendente (true) o descendente (false)
  Future<List<Usuario>> getUsers({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) async {
    final supabase = Supabase.instance.client;

    // Construir la consulta básica
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        supabase.from('usuarios').select('*');

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

    // Aplicar búsqueda textual (en nombre, email y teléfono)
    if (search != null && search.isNotEmpty) {
      query = query.or(
          'nombre.ilike.%$search%,email.ilike.%$search%,telefono.ilike.%$search%');
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

      // Procesar datos y devolver la lista de usuarios
      return response.map((userData) => Usuario.fromMap(userData)).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }
}
