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
  List<String> searchColumns = ['name', 'email', 'phone'];

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModel.fromMap(map);

  /// Obtiene el usuario desde la tabla 'users' filtrando por el auth_id.
  /// [userId] es el auth_id que se utiliza para la búsqueda.
  @override
  Future<UserModel?> getById(
    String userId, {
    String select = '*',
    String field = 'auth_id',
  }) =>
      super.getById(
        userId,
        select: select,
        field: field,
      );
}
