import 'package:ofodep/models/abstract_model.dart';

class UserModel extends ModelComponent {
  final String authId;
  String name;
  String email;
  String phone;
  bool admin;

  UserModel({
    required super.id,
    required this.authId,
    required this.name,
    required this.email,
    required this.phone,
    required this.admin,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      authId: map['auth_id'].toString(),
      name: map['name'].toString(),
      email: map['email'].toString(),
      phone: map['phone'].toString(),
      admin: map['admin'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({
    bool includeId = true,
  }) =>
      {
        if (includeId) 'id': id,
        'auth_id': authId,
        'name': name,
        'email': email,
        'phone': phone,
        'admin': admin,
      };

  @override
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    bool? admin,
  }) {
    return UserModel(
      id: id,
      authId: authId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      admin: admin ?? this.admin,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'UserModel('
      'id: $id, '
      'authId: $authId, '
      'name: $name, '
      'email: $email, '
      'phone: $phone, '
      'admin: $admin, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
