import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/enums.dart';
import 'package:ofodep/models/order_product_model.dart';

class OrderModel extends ModelComponent {
  final String storeId;
  final String storeName;
  final String userId;

  String customerName;
  String customerEmail;
  String customerPhone;

  String addressStreet;
  String addressNumber;
  String addressColony;
  String addressZipcode;
  String addressCity;
  String addressState;

  num locationLat;
  num locationLng;

  DeliveryMethod deliveryMethod;
  num deliveryPrice;
  num total;

  OrderStatus status;
  bool active;
  DateTime? cancellationRequest;

  List<OrderProductModel>? products;

  OrderModel({
    required super.id,
    required this.storeName,
    required this.storeId,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.addressStreet,
    required this.addressNumber,
    required this.addressColony,
    required this.addressZipcode,
    required this.addressCity,
    required this.addressState,
    required this.locationLat,
    required this.locationLng,
    required this.deliveryMethod,
    this.deliveryPrice = 0,
    required this.total,
    this.status = OrderStatus.pending,
    this.active = true,
    this.cancellationRequest,
    super.createdAt,
    super.updatedAt,
    this.products,
  });

  @override
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      storeId: map['store_id'],
      storeName: map['stores']?['name'] ?? '',
      userId: map['user_id'],
      customerName: map['customer_name'],
      customerEmail: map['customer_email'],
      customerPhone: map['customer_phone'],
      addressStreet: map['address_street'],
      addressNumber: map['address_number'],
      addressColony: map['address_colony'],
      addressZipcode: map['address_zipcode'],
      addressCity: map['address_city'],
      addressState: map['address_state'],
      locationLat: map['location_lat'],
      locationLng: map['location_lng'],
      deliveryMethod: DeliveryMethod.fromString(map['delivery_method']),
      deliveryPrice: map['delivery_price'] ?? 0,
      total: map['total'],
      status: OrderStatus.fromString(map['status']),
      active: map['active'] ?? true,
      cancellationRequest: map['cancellation_request'] != null
          ? DateTime.tryParse(map['cancellation_request'])
          : null,
      products: (map['products'] as List?)
          ?.map((e) => OrderProductModel.fromMap(e))
          .toList(),
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'store_id': storeId,
        'user_id': userId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'address_street': addressStreet,
        'address_number': addressNumber,
        'address_colony': addressColony,
        'address_zipcode': addressZipcode,
        'address_city': addressCity,
        'address_state': addressState,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'delivery_method': deliveryMethod.toShortString(),
        'delivery_price': deliveryPrice,
        'total': total,
        'status': status.toShortString(),
        'active': active,
        'cancellation_request': cancellationRequest?.toIso8601String(),
        'products': products?.map((product) => product.toMap()).toList(),
      };

  @override
  OrderModel copyWith({
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    bool? active,
    OrderStatus? status,
    DateTime? cancellationRequest,
    List<OrderProductModel>? products,
  }) {
    return OrderModel(
      id: id,
      storeId: storeId,
      storeName: storeName,
      userId: userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      addressStreet: addressStreet,
      addressNumber: addressNumber,
      addressColony: addressColony,
      addressZipcode: addressZipcode,
      addressCity: addressCity,
      addressState: addressState,
      locationLat: locationLat,
      locationLng: locationLng,
      deliveryMethod: deliveryMethod,
      deliveryPrice: deliveryPrice,
      total: total,
      status: status ?? this.status,
      active: active ?? this.active,
      cancellationRequest: cancellationRequest ?? this.cancellationRequest,
      createdAt: createdAt,
      updatedAt: updatedAt,
      products: products ?? this.products,
    );
  }
}
