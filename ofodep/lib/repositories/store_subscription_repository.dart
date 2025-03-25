import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreSubscriptionRepository extends Repository<StoreSubscriptionModel> {
  @override
  String get tableName => 'store_subscriptions';

  @override
  StoreSubscriptionModel fromMap(Map<String, dynamic> map) =>
      StoreSubscriptionModel.fromMap(map);

  @override
  Future<StoreSubscriptionModel?> getById(
    String id, {
    String select = '*, stores(name)',
    String field = 'store_id',
  }) =>
      super.getById(
        id,
        select: select,
        field: field,
      );

  @override
  Future<List<StoreSubscriptionModel>> getPaginated({
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
