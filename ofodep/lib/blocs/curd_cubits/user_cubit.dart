import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';

class UserCubit extends CrudCubit<UserModel, UserRepository> {
  UserCubit({
    super.repository = const UserRepository(),
    super.initialState,
  });
}
