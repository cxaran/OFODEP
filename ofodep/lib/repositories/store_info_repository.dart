import 'package:ofodep/models/store_info_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreInfoRepository extends Repository<StoreInfoModel> {
  const StoreInfoRepository();
  @override
  String get tableName => 'store_info';

  @override
  StoreInfoModel fromMap(Map<String, dynamic> map) =>
      StoreInfoModel.fromMap(map);
}
