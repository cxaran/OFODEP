import 'package:ofodep/models/usuario.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  Future<Usuario?> getUserByAuthId(String authId) async {
    try {
      final data = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return Usuario.fromMap(data);
    } catch (e) {
      return null;
    }
  }
}
