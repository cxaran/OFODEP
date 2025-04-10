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
  String get fieldId => 'auth_id';

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModel.fromMap(map);
}
