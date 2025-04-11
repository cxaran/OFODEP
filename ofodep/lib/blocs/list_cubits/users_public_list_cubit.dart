import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/user_public_model.dart';
import 'package:ofodep/repositories/user_public_repository.dart';

class UsersPublicListCubit
    extends ListCubit<UserPublicModel, UserPublicRepository> {
  UsersPublicListCubit({
    super.repository = const UserPublicRepository(),
    super.initialState,
  });
}
