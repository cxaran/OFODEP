import 'package:ofodep/models/abstract_model.dart';

class StoreScheduleExceptionModel extends ModelComponent {
  final String storeId;
  DateTime date;
  bool isClosed;
  String? openingTime;
  String? closingTime;

  StoreScheduleExceptionModel({
    required super.id,
    required this.storeId,
    required this.date,
    this.isClosed = false,
    this.openingTime,
    this.closingTime,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreScheduleExceptionModel.fromMap(Map<String, dynamic> map) {
    return StoreScheduleExceptionModel(
      id: map['id'],
      storeId: map['store_id'],
      date: DateTime.parse(map['date']),
      isClosed: map['is_closed'] ?? false,
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
        'date': date.toIso8601String(),
        'is_closed': isClosed,
        'opening_time': openingTime,
        'closing_time': closingTime,
      };

  @override
  StoreScheduleExceptionModel copyWith({
    DateTime? date,
    bool? isClosed,
    String? openingTime,
    String? closingTime,
  }) {
    return StoreScheduleExceptionModel(
      id: id,
      storeId: storeId,
      date: date ?? this.date,
      isClosed: isClosed ?? this.isClosed,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
