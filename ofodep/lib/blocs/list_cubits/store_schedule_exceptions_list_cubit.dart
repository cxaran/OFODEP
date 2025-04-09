import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/repositories/store_schedule_exception_repository.dart';

class StoreScheduleExceptionsListCubit
    extends ListCubit<StoreScheduleExceptionModel> {
  String? storeId;

  StoreScheduleExceptionsListCubit({
    this.storeId,
    StoreScheduleExceptionRepository? storeScheduleExceptionRepository,
    super.limit,
  }) : super(
          initialState: const FilterState(),
          repository: storeScheduleExceptionRepository ??
              StoreScheduleExceptionRepository(),
        );

  @override
  Future<List<StoreScheduleExceptionModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) {
    if (storeId != null) {
      filter ??= {};
      filter['store_id'] = storeId;
    }
    return repository.getPaginated(
      page: page,
      limit: limit,
      filter: filter,
      search: search,
      orderBy: orderBy,
      ascending: ascending,
    );
  }
}
