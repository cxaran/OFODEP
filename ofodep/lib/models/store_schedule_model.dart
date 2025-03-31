import 'package:flutter/material.dart';
import 'package:ofodep/models/abstract_model.dart';

class StoreScheduleModel extends ModelComponent {
  final String storeId;
  List<int> days;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  StoreScheduleModel({
    required super.id,
    required this.storeId,
    required this.days,
    this.openingTime,
    this.closingTime,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory StoreScheduleModel.fromMap(Map<String, dynamic> map) {
    return StoreScheduleModel(
      id: map['id'],
      storeId: map['store_id'],
      days: (map['days'] as List).map((e) => e as int).toList(),
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
        'days': days,
        'opening_time': openingTime == null
            ? null
            : '${openingTime!.hour}:${openingTime!.minute}:00',
        'closing_time': closingTime == null
            ? null
            : '${closingTime!.hour}:${closingTime!.minute}:00',
      };

  @override
  StoreScheduleModel copyWith({
    List<int>? days,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
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
