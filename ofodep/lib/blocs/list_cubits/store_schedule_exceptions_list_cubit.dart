import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/repositories/store_schedule_exception_repository.dart';

class StoreScheduleExceptionsListCubit extends ListCubit<
    StoreScheduleExceptionModel, StoreScheduleExceptionRepository> {
  final String storeId;

  StoreScheduleExceptionsListCubit({
    super.repository = const StoreScheduleExceptionRepository(),
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
