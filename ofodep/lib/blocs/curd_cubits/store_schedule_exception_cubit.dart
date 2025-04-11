import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/repositories/store_schedule_exception_repository.dart';

class StoreScheduleExceptionCubit extends CrudCubit<StoreScheduleExceptionModel,
    StoreScheduleExceptionRepository> {
  StoreScheduleExceptionCubit({
    super.repository = const StoreScheduleExceptionRepository(),
    super.initialState,
  });
}
