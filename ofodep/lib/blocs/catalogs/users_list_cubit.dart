import 'package:ofodep/blocs/catalogs/abstract_list_cubit.dart';
import 'package:ofodep/blocs/catalogs/filter_state.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';

class UsersListCubit extends ListCubit<UserModel, BasicListFilterState> {
  UsersListCubit({UserRepository? userRepository, super.limit})
      : super(
          initialState: const BasicListFilterState(),
          repository: userRepository ?? UserRepository(),
        );
}
