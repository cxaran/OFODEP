import 'package:ofodep/models/localizacion/ubicacion.dart';

class Pedido {
  // Campos del pedido
  final String id;
  final String comercioId;
  final String usuarioId;
  final String nombreCliente;
  final String emailCliente;
  final String telefonoCliente;
  final String? direccionCalle;
  final String? direccionNumero;
  final String? direccionColonia;
  final String? direccionCP;
  final String? direccionCiudad;
  final String? direccionEstado;
  final Ubicacion? ubicacion;
  final double? ubicacionLat;
  final double? ubicacionLng;
  final String? zonaId;
  final String metodoEntrega;
  final double precioDelivery;
  final double total;
  final String estado;
  final bool activo;
  final DateTime? solicitudCancelacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pedido({
    this.id,
    required this.comercioId,
    required this.usuarioId,
    this.nombreCliente,
    this.emailCliente,
    this.telefonoCliente,
    this.direccionCalle,
    this.direccionNumero,
    this.direccionColonia,
    this.direccionCP,
    this.direccionCiudad,
    this.direccionEstado,
    this.ubicacionLat,
    this.ubicacionLng,
    this.zonaId,
    required this.metodoEntrega,
    required this.precioDelivery,
    required this.total,
    required this.estado,
    required this.activo,
    this.solicitudCancelacion,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor para crear un objeto Pedido a partir de un Map (por ejemplo, al consultar la DB)
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] as String?,
      comercioId: map['comercio_id'] as String,
      usuarioId: map['usuario_id'] as String,
      nombreCliente: map['nombre_cliente'] as String?,
      emailCliente: map['email_cliente'] as String?,
      telefonoCliente: map['telefono_cliente'] as String?,
      direccionCalle: map['direccion_calle'] as String?,
      direccionNumero: map['direccion_numero'] as String?,
      direccionColonia: map['direccion_colonia'] as String?,
      direccionCP: map['direccion_cp'] as String?,
      direccionCiudad: map['direccion_ciudad'] as String?,
      direccionEstado: map['direccion_estado'] as String?,
      ubicacionLat: (map['ubicacion_lat'] as num?)?.toDouble(),
      ubicacionLng: (map['ubicacion_lng'] as num?)?.toDouble(),
      zonaId: map['zona_id'] as String?,
      metodoEntrega: map['metodo_entrega'] as String,
      precioDelivery: (map['precio_delivery'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      estado: map['estado'] as String,
      activo: map['activo'] as bool,
      solicitudCancelacion: map['solicitud_cancelacion'] != null
          ? DateTime.parse(map['solicitud_cancelacion'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
