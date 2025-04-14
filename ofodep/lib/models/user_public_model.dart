import 'package:ofodep/models/abstract_model.dart';

class UserPublicModel extends ModelComponent {
  String name;
  String? picture;

  UserPublicModel({
    super.id,
    required this.name,
    this.picture,
    super.createdAt,
    super.updatedAt,
  });

  factory UserPublicModel.fromMap(Map<String, dynamic> map) {
    return UserPublicModel(
      id: map['id'] as String,
      name: map['name'],
      picture: map['picture'],
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
        'name': name,
        'picture': picture,
      };

  @override
  UserPublicModel copyWith({
    String? id,
    String? name,
    String? picture,
  }) {
    return UserPublicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'UserPublicModel('
      'id: $id, '
      'name: $name, '
      'picture: $picture, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
