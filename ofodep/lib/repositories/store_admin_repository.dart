import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreAdminRepository extends Repository<StoreAdminModel> {
  @override
  String get tableName => 'store_admins';

  @override
  StoreAdminModel fromMap(Map<String, dynamic> map) =>
      StoreAdminModel.fromMap(map);

  @override
  Future<StoreAdminModel?> getById(
    String id, {
    String select = '*, stores(name)',
    String field = 'id',
  }) async =>
      super.getById(
        id,
        select: select,
        field: field,
      );

  @override
  Future<List<StoreAdminModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    String? orderBy,
    bool ascending = false,
    String select = '*, stores(name)',
  }) async =>
      super.getPaginated(
        page: page,
        limit: limit,
        filter: filter,
        search: search,
        searchColumns: searchColumns,
        orderBy: orderBy,
        ascending: ascending,
        select: select,
      );
}
