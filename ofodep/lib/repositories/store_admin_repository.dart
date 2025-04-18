import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreAdminRepository extends Repository<StoreAdminModel> {
  const StoreAdminRepository();
  @override
  String get tableName => 'store_admins';

  @override
  String get select => '*, stores(name), users(name)';

  @override
  StoreAdminModel fromMap(Map<String, dynamic> map) =>
      StoreAdminModel.fromMap(map);
}
