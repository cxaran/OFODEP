import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/store_repository.dart';

class StoresListCubit extends ListCubit<StoreModel, StoreRepository> {
  StoresListCubit({
    super.repository = const StoreRepository(),
    super.initialState,
  });
}
