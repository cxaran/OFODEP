import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreSubscriptionRepository extends Repository<StoreSubscriptionModel> {
  @override
  String get tableName => 'store_subscriptions';

  @override
  String get select => '*, stores(name)';

  @override
  String get fieldId => 'store_id';

  @override
  StoreSubscriptionModel fromMap(Map<String, dynamic> map) =>
      StoreSubscriptionModel.fromMap(map);
}
