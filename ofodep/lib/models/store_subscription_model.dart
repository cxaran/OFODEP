import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/enums.dart';

class StoreSubscriptionModel extends ModelComponent {
  final String storeId;
  String? storeName;
  final SubscriptionType subscriptionType;
  DateTime expirationDate;

  StoreSubscriptionModel({
    super.id,
    required this.storeId,
    this.storeName,
    required this.subscriptionType,
    required this.expirationDate,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreSubscriptionModel.fromMap(Map<String, dynamic> map) {
    return StoreSubscriptionModel(
      id: map['id'],
      storeId: map['store_id'],
      storeName: map['stores']?['name'] ?? '',
      subscriptionType: SubscriptionType.fromString(map['subscription_type']),
      expirationDate: DateTime.parse(map['expiration_date']),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'store_id': storeId,
        'subscription_type': subscriptionType.description,
        'expiration_date': expirationDate.toIso8601String(),
      };

  @override
  StoreSubscriptionModel copyWith({
    String? id,
    SubscriptionType? subscriptionType,
    DateTime? expirationDate,
  }) {
    return StoreSubscriptionModel(
      id: id ?? this.id,
      storeId: storeId,
      storeName: storeName,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'StoreSubscriptionModel('
      'id: $id, '
      'storeId: $storeId, '
      'storeName: $storeName, '
      'subscriptionType: $subscriptionType, '
      'expirationDate: $expirationDate'
      ')';
}
