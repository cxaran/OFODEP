import 'package:ofodep/models/abstract_model.dart';

class StoreAdminModel extends ModelComponent {
  // Datos de el comercio
  final String storeId;
  final String? storeName;
  // Datos de la cuenta de usuario
  final String userId;
  final String? userName;
  final String? userEmail;
  // Datos de contacto
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  // Bandera de contacto principal
  bool? isPrimaryContact;

  StoreAdminModel({
    super.id,
    required this.storeId,
    this.storeName,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    this.isPrimaryContact,
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
      userName: map['users']?['name'],
      userEmail: map['users']?['email'],
      contactName: map['contact_name'],
      contactEmail: map['contact_email'],
      contactPhone: map['contact_phone'],
      isPrimaryContact: map['is_primary_contact'],
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'store_id': storeId,
        'user_id': userId,
        'contact_name': contactName,
        'contact_email': contactEmail,
        'contact_phone': contactPhone,
        'is_primary_contact': isPrimaryContact,
      };

  @override
  StoreAdminModel copyWith({
    String? id,
    String? storeId,
    String? storeName,
    String? userId,
    String? userName,
    String? userEmail,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    bool? isPrimaryContact,
  }) {
    return StoreAdminModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'StoreAdminModel('
      'id: $id, '
      'storeId: $storeId, '
      'storeName: $storeName, '
      'userId: $userId, '
      'userName: $userName, '
      'userEmail: $userEmail, '
      'contactName: $contactName, '
      'contactEmail: $contactEmail, '
      'contactPhone: $contactPhone, '
      'isPrimaryContact: $isPrimaryContact, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
