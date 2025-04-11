import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/repositories/store_schedules_repository.dart';

class StoreScheduleCubit
    extends CrudCubit<StoreScheduleModel, StoreScheduleRepository> {
  StoreScheduleCubit({
    super.repository = const StoreScheduleRepository(),
    super.initialState,
  });
}
