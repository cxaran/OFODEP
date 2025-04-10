import 'package:ofodep/models/abstract_model.dart';

class OrderOptionModel extends ModelComponent {
  final String orderItemConfigurationId;
  final String optionId;
  int quantity;
  num extraPrice;

  OrderOptionModel({
    required super.id,
    required this.orderItemConfigurationId,
    required this.optionId,
    this.quantity = 0,
    this.extraPrice = 0,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory OrderOptionModel.fromMap(Map<String, dynamic> map) {
    return OrderOptionModel(
      id: map['id'],
      orderItemConfigurationId: map['order_item_configuration_id'],
      optionId: map['option_id'],
      quantity: map['quantity'],
      extraPrice: map['extra_price'],
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'order_item_configuration_id': orderItemConfigurationId,
        'option_id': optionId,
        'quantity': quantity,
        'extra_price': extraPrice,
      };

  @override
  OrderOptionModel copyWith({
    String? id,
    int? quantity,
    num? extraPrice,
  }) {
    return OrderOptionModel(
      id: id ?? this.id,
      orderItemConfigurationId: orderItemConfigurationId,
      optionId: optionId,
      quantity: quantity ?? this.quantity,
      extraPrice: extraPrice ?? this.extraPrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
