class PedidoOpcion {
  final String id;
  final String pedidoItemConfiguracionId;
  final String opcionId;
  int cantidad;
  num precioExtra;
  DateTime createdAt;
  DateTime updatedAt;

  PedidoOpcion({
    required this.id,
    required this.pedidoItemConfiguracionId,
    required this.opcionId,
    this.cantidad = 0,
    this.precioExtra = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PedidoOpcion.fromMap(Map<String, dynamic> map) {
    return PedidoOpcion(
      id: map['id'] as String,
      pedidoItemConfiguracionId: map['pedido_item_configuracion_id'].toString(),
      opcionId: map['opcion_id'].toString(),
      cantidad: map['cantidad'] as int? ?? 0,
      precioExtra: map['precio_extra'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}