import 'package:ofodep/models/abstract_model.dart';

class StoreScheduleModel extends ModelComponent {
  final String storeId;
  List<int> days;
  String openingTime;
  String closingTime;

  StoreScheduleModel({
    required super.id,
    required this.storeId,
    required this.days,
    required this.openingTime,
    required this.closingTime,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreScheduleModel.fromMap(Map<String, dynamic> map) {
    return StoreScheduleModel(
      id: map['id'],
      storeId: map['store_id'],
      days: (map['days'] as List).map((e) => e as int).toList(),
      openingTime: map['opening_time'],
      closingTime: map['closing_time'],
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'store_id': storeId,
        'days': days,
        'opening_time': openingTime,
        'closing_time': closingTime,
      };

  @override
  StoreScheduleModel copyWith({
    List<int>? days,
    String? openingTime,
    String? closingTime,
  }) {
    return StoreScheduleModel(
      id: id,
      storeId: storeId,
      days: days ?? this.days,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
