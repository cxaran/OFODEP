import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/repositories/store_schedules_repository.dart';

class StoreSchedulesListCubit
    extends ListCubit<StoreScheduleModel, StoreScheduleRepository> {
  final String storeId;

  StoreSchedulesListCubit({
    super.repository = const StoreScheduleRepository(),
    super.initialState,
    required this.storeId,
  });

  @override
  Map<String, dynamic>? getFilter(Map<String, dynamic>? filter) {
    filter ??= {};
    filter['store_id'] = storeId;
    return filter;
  }
}
