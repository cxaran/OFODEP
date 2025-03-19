class PedidoProducto {
  final String id;
  final String pedidoId;
  final String productoId;
  int cantidad;
  num precio;
  DateTime createdAt;
  DateTime updatedAt;

  PedidoProducto({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    this.cantidad = 1,
    required this.precio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PedidoProducto.fromMap(Map<String, dynamic> map) {
    return PedidoProducto(
      id: map['id'] as String,
      pedidoId: map['pedido_id'].toString(),
      productoId: map['producto_id'].toString(),
      cantidad: map['cantidad'] as int? ?? 1,
      precio: map['precio'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}