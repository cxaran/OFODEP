import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  Future<UserModel?> getUserByAuthId(String authId) async {
    try {
      final data = await Supabase.instance.client
          .from(UserRepository.tableName)
          .select()
          .eq('auth_id', authId)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return UserModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }
}
