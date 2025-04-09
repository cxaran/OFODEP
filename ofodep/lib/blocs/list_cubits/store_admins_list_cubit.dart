import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/repositories/store_admin_repository.dart';

class StoreAdminsListCubit extends ListCubit<StoreAdminModel> {
  String? storeId;

  StoreAdminsListCubit({
    this.storeId,
    StoreAdminRepository? storeAdminRepository,
    super.limit,
  }) : super(
          initialState: const FilterState(),
          repository: storeAdminRepository ?? StoreAdminRepository(),
        );

  @override
  Future<List<StoreAdminModel>> getPaginated({
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
