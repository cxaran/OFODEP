import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

/// Implementación del repositorio de usuarios que extiende de Repository.
/// Se aprovecha la implementación genérica, pero se ajusta el método getById
/// para buscar por `auth_id` y se sobreescribe getPaginated para aplicar la búsqueda
/// en las columnas name, email y phone.
class UserRepository extends Repository<UserModel> {
  @override
  String get tableName => 'users';

  @override
  UserModel fromMap(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }

  /// Obtiene el usuario desde la tabla 'users' filtrando por el auth_id.
  /// [userId] es el auth_id que se utiliza para la búsqueda.
  @override
  Future<UserModel?> getById(String userId) async {
    try {
      final data = await client
          .from(tableName)
          .select()
          .eq('auth_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return fromMap(data);
    } catch (e) {
      throw Exception('error(getById): $e');
    }
  }

  /// Obtiene una lista paginada de usuarios, aplicando búsqueda textual en las columnas
  /// name, email y phone (si no se especifican otras columnas en [searchColumns]).
  @override
  Future<List<UserModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    String? orderBy,
    bool ascending = false,
  }) async {
    // Si no se proveen columnas para la búsqueda, se utilizan por defecto.
    final columns = searchColumns ?? ['name', 'email', 'phone'];
    return super.getPaginated(
      page: page,
      limit: limit,
      filter: filter,
      search: search,
      searchColumns: columns,
      orderBy: orderBy,
      ascending: ascending,
    );
  }
}
