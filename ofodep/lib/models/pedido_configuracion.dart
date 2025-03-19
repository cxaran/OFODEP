class PedidoConfiguracion {
  final String id;
  final String pedidoItemId;
  final String configuracionId;
  DateTime createdAt;
  DateTime updatedAt;

  PedidoConfiguracion({
    required this.id,
    required this.pedidoItemId,
    required this.configuracionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PedidoConfiguracion.fromMap(Map<String, dynamic> map) {
    return PedidoConfiguracion(
      id: map['id'] as String,
      pedidoItemId: map['pedido_item_id'].toString(),
      configuracionId: map['configuracion_id'].toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}