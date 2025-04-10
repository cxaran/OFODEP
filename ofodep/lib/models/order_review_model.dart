import 'package:ofodep/models/abstract_model.dart';

class OrderReviewModel extends ModelComponent {
  final String orderId;
  num rating;
  String? review;

  OrderReviewModel({
    required super.id,
    required this.orderId,
    required this.rating,
    this.review,
    super.createdAt,
    super.updatedAt,
  });

  @override
  factory OrderReviewModel.fromMap(Map<String, dynamic> map) {
    return OrderReviewModel(
      id: map['id'],
      orderId: map['order_id'],
      rating: map['rating'],
      review: map['review'],
      createdAt: DateTime.tryParse(map['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap({bool includeId = true}) => {
        if (includeId) 'id': id,
        'order_id': orderId,
        'rating': rating,
        'review': review,
      };

  @override
  OrderReviewModel copyWith({
    String? id,
    num? rating,
    String? review,
  }) {
    return OrderReviewModel(
      id: id ?? this.id,
      orderId: orderId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
