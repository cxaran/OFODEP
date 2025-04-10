import 'package:ofodep/models/admin_global_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class AdminGlobalRepository extends Repository<AdminGlobalModel> {
  @override
  String get tableName => 'admin_global';

  @override
  String get fieldId => 'auth_id';

  @override
  AdminGlobalModel fromMap(Map<String, dynamic> map) =>
      AdminGlobalModel.fromMap(map);
}
