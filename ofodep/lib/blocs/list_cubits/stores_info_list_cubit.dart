import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/store_info_model.dart';
import 'package:ofodep/repositories/store_info_repository.dart';

class StoresInfoListCubit
    extends ListCubit<StoreInfoModel, StoreInfoRepository> {
  StoresInfoListCubit({
    super.repository = const StoreInfoRepository(),
    super.initialState,
  });
}
