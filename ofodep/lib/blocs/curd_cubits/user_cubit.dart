import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';

class UserCubit extends CrudCubit<UserModel> {
  UserCubit({required super.id, UserRepository? userRepository})
      : super(
          repository: userRepository ?? UserRepository(),
        );

  /// Actualiza el campo 'name' en el modelo en edición.
  void nameChanged(String name) {
    updateEditingState((user) => user.copyWith(name: name));
  }

  /// Actualiza el campo 'phone' en el modelo en edición.
  void phoneChanged(String phone) {
    updateEditingState((user) => user.copyWith(phone: phone));
  }

  /// Actualiza el flag 'admin' en el modelo en edición.
  void adminChanged(bool admin) {
    updateEditingState((user) => user.copyWith(admin: admin));
  }

  /// Sobrescribe el submit para agregar validaciones específicas antes de enviar.
  @override
  Future<void> submit() async {
    final current = state;
    if (current is CrudEditing<UserModel>) {
      // Validación: nombre y teléfono obligatorios.
      if (current.editedModel.name.trim().isEmpty) {
        emit(current.copyWith(errorMessage: "name"));
        return;
      }
      // Validación: el teléfono debe cumplir el formato.
      if (!RegExp(r'^\+?[0-9]{7,15}$')
          .hasMatch(current.editedModel.phone ?? '')) {
        emit(current.copyWith(errorMessage: "phone"));
        return;
      }
    }
    await super.submit();
  }
}
