class PedidoReview {
  final String id;
  final String pedidoId;
  num calificacion;
  String? review;
  DateTime createdAt;
  DateTime updatedAt;

  PedidoReview({
    required this.id,
    required this.pedidoId,
    required this.calificacion,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PedidoReview.fromMap(Map<String, dynamic> map) {
    return PedidoReview(
      id: map['id'] as String,
      pedidoId: map['pedido_id'].toString(),
      calificacion: map['calificacion'],
      review: map['review'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}