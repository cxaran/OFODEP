import 'package:ofodep/models/abstract_model.dart';

class StoreAdminModel extends ModelComponent {
  final String storeId;
  final String userId;

  StoreAdminModel({
    required super.id,
    required this.storeId,
    required this.userId,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreAdminModel.fromMap(Map<String, dynamic> map) {
    return StoreAdminModel(
      id: map['id'],
      storeId: map['store_id'],
      userId: map['user_id'],
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'store_id': storeId,
        'user_id': userId,
      };

  @override
  StoreAdminModel copyWith({
    String? storeId,
    String? userId,
  }) {
    return StoreAdminModel(
      id: id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
