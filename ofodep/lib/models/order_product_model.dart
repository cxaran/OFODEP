import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/order_configuration_model.dart';

class OrderProductModel extends ModelComponent {
  final String orderId;
  final String productId;
  int quantity;
  num price;

  List<OrderConfigurationModel>? configurations;

  OrderProductModel({
    required super.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.configurations,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory OrderProductModel.fromMap(Map<String, dynamic> map) {
    return OrderProductModel(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      price: map['price'],
      configurations: (map['configurations'] as List?)
          ?.map((e) => OrderConfigurationModel.fromMap(e))
          .toList(),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };

  @override
  OrderProductModel copyWith({
    String? id,
    int? quantity,
    num? price,
    List<OrderConfigurationModel>? configurations,
  }) {
    return OrderProductModel(
      id: id ?? this.id,
      orderId: orderId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      configurations: configurations ?? this.configurations,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
