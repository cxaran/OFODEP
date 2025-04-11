import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/create_store_model.dart';
import 'package:ofodep/repositories/create_store_repository.dart';

class CreateStoreCubit
    extends CrudCubit<CreateStoreModel, CreateStoreRepository> {
  CreateStoreCubit({
    super.repository = const CreateStoreRepository(),
    super.initialState,
  });
}
