import 'enums.dart';

class Pedido {
  final String id;
  final String comercioId;
  final String usuarioId;
  String? nombreCliente;
  String? emailCliente;
  String? telefonoCliente;
  String? direccionCalle;
  String? direccionNumero;
  String? direccionColonia;
  String? direccionCp;
  String? direccionCiudad;
  String? direccionEstado;
  num? ubicacionLat;
  num? ubicacionLng;
  String? zonaId;
  final MetodoEntrega metodoEntrega;
  num precioDelivery;
  num total;
  final EstadoPedido estado;
  bool activo;
  DateTime? solicitudCancelacion;
  DateTime createdAt;
  DateTime updatedAt;

  Pedido({
    required this.id,
    required this.comercioId,
    required this.usuarioId,
    this.nombreCliente,
    this.emailCliente,
    this.telefonoCliente,
    this.direccionCalle,
    this.direccionNumero,
    this.direccionColonia,
    this.direccionCp,
    this.direccionCiudad,
    this.direccionEstado,
    this.ubicacionLat,
    this.ubicacionLng,
    this.zonaId,
    required this.metodoEntrega,
    this.precioDelivery = 0,
    required this.total,
    required this.estado,
    this.activo = true,
    this.solicitudCancelacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] as String,
      comercioId: map['comercio_id'].toString(),
      usuarioId: map['usuario_id'].toString(),
      nombreCliente: map['nombre_cliente'] as String?,
      emailCliente: map['email_cliente'] as String?,
      telefonoCliente: map['telefono_cliente'] as String?,
      direccionCalle: map['direccion_calle'] as String?,
      direccionNumero: map['direccion_numero'] as String?,
      direccionColonia: map['direccion_colonia'] as String?,
      direccionCp: map['direccion_cp'] as String?,
      direccionCiudad: map['direccion_ciudad'] as String?,
      direccionEstado: map['direccion_estado'] as String?,
      ubicacionLat: map['ubicacion_lat'],
      ubicacionLng: map['ubicacion_lng'],
      zonaId: map['zona_id']?.toString(),
      metodoEntrega: MetodoEntregaExtension.fromString(map['metodo_entrega']),
      precioDelivery: map['precio_delivery'] ?? 0,
      total: map['total'],
      estado: EstadoPedidoExtension.fromString(map['estado']),
      activo: map['activo'] as bool? ?? true,
      solicitudCancelacion: map['solicitud_cancelacion'] != null
          ? DateTime.parse(map['solicitud_cancelacion'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}