import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreScheduleExceptionRepository
    extends Repository<StoreScheduleExceptionModel> {
  @override
  String get tableName => 'store_schedule_exceptions';

  @override
  StoreScheduleExceptionModel fromMap(Map<String, dynamic> map) =>
      StoreScheduleExceptionModel.fromMap(map);
}
