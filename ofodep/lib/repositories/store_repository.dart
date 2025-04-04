import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreRepository extends Repository<StoreModel> {
  @override
  String get tableName => 'stores';

  @override
  List<String> searchColumns = [
    'name',
    'address_street',
    'address_state',
    'address_city',
    'address_colony',
    'address_number',
    'address_zipcode',
    'whatsapp',
  ];

  @override
  String get select => '*, store_is_open';

  @override
  StoreModel fromMap(Map<String, dynamic> map) => StoreModel.fromMap(map);
}
