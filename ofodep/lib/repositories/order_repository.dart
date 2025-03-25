import 'package:ofodep/models/order_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class OrderRepository extends Repository<OrderModel> {
  @override
  String get tableName => 'orders';

  @override
  List<String> searchColumns = ['customer_name'];

  @override
  OrderModel fromMap(Map<String, dynamic> map) => OrderModel.fromMap(map);

  @override
  Future<OrderModel?> getById(
    String id, {
    String select = '*, store(name)',
    String field = 'id',
  }) async =>
      super.getById(
        id,
        select: select,
        field: field,
      );

  @override
  Future<List<OrderModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    String? orderBy,
    bool ascending = false,
    String select = '*, store(name)',
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
