import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/order_option_model.dart';

class OrderConfigurationModel extends ModelComponent {
  final String orderItemId;
  final String configurationId;

  List<OrderOptionModel>? options;

  OrderConfigurationModel({
    required super.id,
    required this.orderItemId,
    required this.configurationId,
    this.options,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory OrderConfigurationModel.fromMap(Map<String, dynamic> map) {
    return OrderConfigurationModel(
      id: map['id'],
      orderItemId: map['order_item_id'],
      configurationId: map['configuration_id'],
      options: (map['options'] as List?)
          ?.map((e) => OrderOptionModel.fromMap(e))
          .toList(),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'order_item_id': orderItemId,
        'configuration_id': configurationId,
      };

  @override
  OrderConfigurationModel copyWith({
    String? configurationId,
    List<OrderOptionModel>? options,
  }) {
    return OrderConfigurationModel(
      id: id,
      orderItemId: orderItemId,
      configurationId: configurationId ?? this.configurationId,
      options: options ?? this.options,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
