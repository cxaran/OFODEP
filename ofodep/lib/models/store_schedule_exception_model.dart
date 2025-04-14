import 'package:flutter/material.dart';
import 'package:ofodep/models/abstract_model.dart';

class StoreScheduleExceptionModel extends ModelComponent {
  final String storeId;
  DateTime date;
  bool isClosed;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  StoreScheduleExceptionModel({
    super.id,
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
      openingTime: map['opening_time'].toString().split(':').length == 3
          ? TimeOfDay(
              hour: int.parse(map['opening_time']!.split(':')[0]),
              minute: int.parse(map['opening_time']!.split(':')[1]),
            )
          : null,
      closingTime: map['closing_time'].toString().split(':').length == 3
          ? TimeOfDay(
              hour: int.parse(map['closing_time']!.split(':')[0]),
              minute: int.parse(map['closing_time']!.split(':')[1]),
            )
          : null,
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
        'opening_time': openingTime == null
            ? null
            : '${openingTime!.hour}:${openingTime!.minute}:00',
        'closing_time': closingTime == null
            ? null
            : '${closingTime!.hour}:${closingTime!.minute}:00',
      };

  @override
  StoreScheduleExceptionModel copyWith({
    String? id,
    DateTime? date,
    bool? isClosed,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
  }) {
    return StoreScheduleExceptionModel(
      id: id ?? this.id,
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
