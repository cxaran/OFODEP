import 'package:flutter/foundation.dart';
import 'package:ofodep/models/pedidos/pedido.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Modelo Usuario
class Usuario {
  final String id;
  final String authId;
  String nombre;
  String email;
  String telefono;
  bool admin;
  DateTime createdAt;
  DateTime updatedAt;

  Usuario({
    required this.id,
    required this.authId,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.admin,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor para crear un objeto a partir de un Map
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as String,
      authId: map['auth_id'].toString(),
      nombre: map['nombre'].toString(),
      email: map['email'].toString(),
      telefono: map['telefono'].toString(),
      admin: map['admin'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Método estático para obtener un usuario por su auth_id
  static Future<Usuario?> findById(String authId) async {
    try {
      final data = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('auth_id', authId)
          .single();

      return Usuario.fromMap(data);
    } catch (error) {
      debugPrint('Error al obtener el usuario con auth_id: $authId - $error');
      return null;
    }
  }

  // Método para actualizar el nombre del usuario
  Future<bool> updateNombre(String nuevoNombre) async {
    try {
      final response = await Supabase.instance.client.from('usuarios').update({
        'nombre': nuevoNombre,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('auth_id', authId);

      if (response.error == null) {
        debugPrint("Nombre actualizado correctamente.");
        nombre = nuevoNombre;
        return true;
      } else {
        debugPrint("Error al actualizar el nombre: ${response.error!.message}");
        return false;
      }
    } catch (error) {
      debugPrint("Excepción al actualizar el nombre - $error");
      return false;
    }
  }

  // Método para actualizar el teléfono del usuario
  Future<bool> updateTelefono(String nuevoTelefono) async {
    try {
      final response = await Supabase.instance.client.from('usuarios').update({
        'telefono': nuevoTelefono,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('auth_id', authId);

      if (response.error == null) {
        debugPrint("Teléfono actualizado correctamente.");
        telefono = nuevoTelefono;
        return true;
      } else {
        debugPrint(
            "Error al actualizar el teléfono: ${response.error!.message}");
        return false;
      }
    } catch (error) {
      debugPrint("Excepción al actualizar el teléfono - $error");
      return false;
    }
  }

  // Método para consultar y actualizar los datos del usuario sin Stream (ahora llamado refresh)
  Future<bool> refresh() async {
    try {
      final data = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('auth_id', authId)
          .single();

      // Actualizar los valores del objeto actual
      nombre = data['nombre'].toString();
      email = data['email'].toString();
      telefono = data['telefono'].toString();
      admin = data['admin'] as bool? ?? false;
      createdAt = DateTime.parse(data['created_at']);
      updatedAt = DateTime.parse(data['updated_at']);

      debugPrint("Datos del usuario actualizados correctamente.");
      return true;
    } catch (error) {
      debugPrint("Error al refrescar los datos del usuario - $error");
      return false;
    }
  }

  // Stream para escuchar cambios en la tabla usuarios
  Stream<Usuario?> escucharCambiosUsuario() {
    return Supabase.instance.client
        .from('usuarios')
        .stream(primaryKey: ['id'])
        .eq('auth_id', authId)
        .map((event) {
          if (event.isNotEmpty) {
            debugPrint("⚡ Datos del usuario actualizados en tiempo real.");
            return Usuario.fromMap(event.first);
          }
          return null;
        });
  }

  Future<List<Pedido>> getPedidos() async {
    try {
      final data = await Supabase.instance.client
          .from('pedidos')
          .select()
          .eq('usuario_id', authId)
          .order('created_at', ascending: false);

      final List<dynamic> list = data;
      return list
          .map((e) => Pedido.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (error) {
      debugPrint('Error al obtener pedidos: $error');
      return [];
    }
  }
}
