import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreScheduleRepository extends Repository<StoreScheduleModel> {
  @override
  String get tableName => 'store_schedules';

  @override
  StoreScheduleModel fromMap(Map<String, dynamic> map) =>
      StoreScheduleModel.fromMap(map);
}
