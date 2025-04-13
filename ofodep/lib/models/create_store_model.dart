import 'package:ofodep/models/abstract_model.dart';

class CreateStoreModel extends ModelComponent {
  // Datos de el comercio
  final String storeName;
  final String countryCode;
  final String timezone;

  // Datos de contacto
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  CreateStoreModel({
    required super.id,
    required this.storeName,
    required this.countryCode,
    required this.timezone,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
  });

  CreateStoreModel.empty()
      : this(
          id: '',
          storeName: '',
          countryCode: '',
          timezone: '',
          contactName: '',
          contactEmail: '',
          contactPhone: '',
        );

  @override
  factory CreateStoreModel.fromMap(Map<String, dynamic> map) {
    return CreateStoreModel(
      id: map['id'],
      storeName: map['store_name'],
      countryCode: map['country_code'],
      timezone: map['timezone'],
      contactName: map['contact_name'],
      contactEmail: map['contact_email'],
      contactPhone: map['contact_phone'],
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        'store_name': storeName,
        'country_code': countryCode,
        'timezone': timezone,
        'contact_name': contactName,
        'contact_email': contactEmail,
        'contact_phone': contactPhone,
      };

  @override
  CreateStoreModel copyWith({
    String? id,
    String? storeName,
    String? countryCode,
    String? timezone,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    bool? isPrimaryContact,
  }) {
    return CreateStoreModel(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  @override
  String toString() => 'CreateStoreModel('
      'id: $id, '
      'storeName: $storeName, '
      'countryCode: $countryCode, '
      'timezone: $timezone, '
      'contactName: $contactName, '
      'contactEmail: $contactEmail, '
      'contactPhone: $contactPhone'
      ')';
}
