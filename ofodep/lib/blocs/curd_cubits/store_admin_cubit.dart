import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/repositories/store_admin_repository.dart';

class StoreAdminCubit extends CrudCubit<StoreAdminModel> {
  StoreAdminCubit({
    required super.id,
    StoreAdminRepository? repository,
  }) : super(
          repository: repository ?? StoreAdminRepository(),
        );
}
