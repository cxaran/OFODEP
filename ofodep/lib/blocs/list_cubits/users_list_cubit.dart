import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';

class UsersListCubit extends ListCubit<UserModel> {
  UsersListCubit({UserRepository? userRepository, super.limit})
      : super(
          initialState: const FilterState(),
          repository: userRepository ?? UserRepository(),
        );
}
