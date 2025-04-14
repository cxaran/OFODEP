import 'package:ofodep/models/abstract_model.dart';

class StoreImagesModel extends ModelComponent {
  // Store ID
  final String storeId;

  // Imgur client ID
  final String imgurClientId;

  // Imgur client secret
  final String imgurClientSecret;

  StoreImagesModel({
    super.id,
    required this.storeId,
    required this.imgurClientId,
    required this.imgurClientSecret,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreImagesModel.fromMap(Map<String, dynamic> map) {
    return StoreImagesModel(
      id: map['id'] as String,
      storeId: map['store_id'] as String,
      imgurClientId: map['imgur_client_id'] as String,
      imgurClientSecret: map['imgur_client_secret'] as String,
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
        'store_id': storeId,
        'imgur_client_id': imgurClientId,
        'imgur_client_secret': imgurClientSecret,
      };

  @override
  StoreImagesModel copyWith({
    String? id,
    String? imgurClientId,
    String? imgurClientSecret,
  }) {
    return StoreImagesModel(
      id: id ?? this.id,
      storeId: storeId,
      imgurClientId: imgurClientId ?? this.imgurClientId,
      imgurClientSecret: imgurClientSecret ?? this.imgurClientSecret,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'StoreImagesModel('
      'id: $id, '
      'storeId: $storeId, '
      'imgurClientId: $imgurClientId, '
      'imgurClientSecret: $imgurClientSecret'
      ')';
}
