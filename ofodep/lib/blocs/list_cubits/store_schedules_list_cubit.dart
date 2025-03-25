import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/repositories/store_schedules_repository.dart';

class StoreSchedulesListCubit
    extends ListCubit<StoreScheduleModel, BasicListFilterState> {
  String storeId;

  StoreSchedulesListCubit({
    required this.storeId,
    StoreScheduleRepository? storeScheduleRepository,
    super.limit,
  }) : super(
          initialState: const BasicListFilterState(),
          repository: storeScheduleRepository ?? StoreScheduleRepository(),
        );

  @override
  Future<List<StoreScheduleModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) {
    filter ??= {};
    filter['store_id'] = storeId;

    return repository.getPaginated(
      page: page,
      limit: limit,
      filter: filter,
      search: search,
      orderBy: orderBy,
      ascending: ascending,
      select: '*, stores(name)',
    );
  }
}
