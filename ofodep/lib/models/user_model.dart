import 'package:ofodep/models/abstract_model.dart';

class UserModel extends ModelComponent {
  final String authId;
  String email;
  String name;
  String? phone;

  UserModel({
    required super.id,
    required this.authId,
    required this.email,
    required this.name,
    this.phone,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      authId: map['auth_id'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
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
        'email': email,
        'name': name,
        'phone': phone,
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
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'UserModel('
      'id: $id, '
      'authId: $authId, '
      'name: $name, '
      'phone: $phone, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
