import 'package:ofodep/models/abstract_model.dart';

class AdminGlobalModel extends ModelComponent {
  final String authId;

  AdminGlobalModel({
    super.id,
    required this.authId,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory AdminGlobalModel.fromMap(Map<String, dynamic> map) {
    return AdminGlobalModel(
      id: map['id'],
      authId: map['auth_id'],
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
      };

  @override
  AdminGlobalModel copyWith({
    String? id,
    String? authId,
  }) {
    return AdminGlobalModel(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'AdminGlobalModel('
      'id: $id, '
      'authId: $authId, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
