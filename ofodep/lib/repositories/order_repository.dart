import 'package:ofodep/models/order_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class OrderRepository extends Repository<OrderModel> {
  @override
  String get tableName => 'orders';

  @override
  List<String> searchColumns = ['customer_name'];

  @override
  String get select => '*, stores(name)';

  @override
  OrderModel fromMap(Map<String, dynamic> map) => OrderModel.fromMap(map);
}
