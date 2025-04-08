import 'package:ofodep/models/abstract_model.dart';

class StoreAdminModel extends ModelComponent {
  final String storeId;
  final String storeName;
  final String userId;

  StoreAdminModel({
    required super.id,
    required this.storeId,
    required this.storeName,
    required this.userId,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreAdminModel.fromMap(Map<String, dynamic> map) {
    return StoreAdminModel(
      id: map['id'],
      storeId: map['store_id'],
      storeName: map['stores']?['name'] ?? '',
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
  StoreAdminModel copyWith() {
    return StoreAdminModel(
      id: id,
      storeId: storeId,
      storeName: storeName,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
