import 'package:ofodep/models/user_public_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class UserPublicRepository extends Repository<UserPublicModel> {
  const UserPublicRepository();
  @override
  String get tableName => 'users_public';

  @override
  UserPublicModel fromMap(Map<String, dynamic> map) =>
      UserPublicModel.fromMap(map);
}
