import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreAdminRepository extends Repository<StoreAdminModel> {
  @override
  String get tableName => 'store_admins';

  @override
  String get select => '*, stores(name)';

  @override
  StoreAdminModel fromMap(Map<String, dynamic> map) =>
      StoreAdminModel.fromMap(map);
}
