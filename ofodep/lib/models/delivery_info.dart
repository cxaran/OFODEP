class DeliveryInfo {
  final String id;
  final String pedidoId;
  String linkToken;
  String? usuarioRepartidor;
  num? repartidorLat;
  num? repartidorLng;
  DateTime createdAt;
  DateTime updatedAt;

  DeliveryInfo({
    required this.id,
    required this.pedidoId,
    required this.linkToken,
    this.usuarioRepartidor,
    this.repartidorLat,
    this.repartidorLng,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryInfo.fromMap(Map<String, dynamic> map) {
    return DeliveryInfo(
      id: map['id'] as String,
      pedidoId: map['pedido_id'].toString(),
      linkToken: map['link_token'].toString(),
      usuarioRepartidor: map['usuario_repartidor']?.toString(),
      repartidorLat: map['repartidor_lat'],
      repartidorLng: map['repartidor_lng'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}