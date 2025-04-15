import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreRepository extends Repository<StoreModel> {
  const StoreRepository();
  @override
  String get tableName => 'stores';

  @override
  String get select =>
      '*, store_subscriptions(expiration_date), store_images(imgur_client_id), store_is_open';

  @override
  StoreModel fromMap(Map<String, dynamic> map) => StoreModel.fromMap(map);
}
