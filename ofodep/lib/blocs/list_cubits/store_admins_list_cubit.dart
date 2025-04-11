import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/repositories/store_admin_repository.dart';

class StoreAdminsListCubit
    extends ListCubit<StoreAdminModel, StoreAdminRepository> {
  final String? storeId;

  StoreAdminsListCubit({
    super.repository = const StoreAdminRepository(),
    super.initialState,
    this.storeId,
  });

  @override
  Map<String, dynamic>? getFilter(Map<String, dynamic>? filter) {
    if (storeId != null) {
      filter ??= {};
      filter['store_id'] = storeId;
    }
    return filter;
  }
}
