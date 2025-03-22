class UserModel {
  final String id;
  final String authId;
  String name;
  String email;
  String phone;
  bool admin;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.authId,
    required this.name,
    required this.email,
    required this.phone,
    required this.admin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      authId: map['auth_id'].toString(),
      name: map['name'].toString(),
      email: map['email'].toString(),
      phone: map['phone'].toString(),
      admin: map['admin'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
