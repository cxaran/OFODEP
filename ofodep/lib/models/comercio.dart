class Comercio {
  final String id;
  String nombre;
  String? logoUrl;
  String? direccionCalle;
  String? direccionNumero;
  String? direccionColonia;
  String? direccionCp;
  String? direccionCiudad;
  String? direccionEstado;
  num? lat;
  num? lng;
  String? whatsapp;
  num? minimoCompraDelivery;
  bool pickup;
  bool delivery;
  num? precioDelivery;
  DateTime createdAt;
  DateTime updatedAt;

  Comercio({
    required this.id,
    required this.nombre,
    this.logoUrl,
    this.direccionCalle,
    this.direccionNumero,
    this.direccionColonia,
    this.direccionCp,
    this.direccionCiudad,
    this.direccionEstado,
    this.lat,
    this.lng,
    this.whatsapp,
    this.minimoCompraDelivery,
    this.pickup = false,
    this.delivery = false,
    this.precioDelivery,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comercio.fromMap(Map<String, dynamic> map) {
    return Comercio(
      id: map['id'] as String,
      nombre: map['nombre'].toString(),
      logoUrl: map['logo_url'] as String?,
      direccionCalle: map['direccion_calle'] as String?,
      direccionNumero: map['direccion_numero'] as String?,
      direccionColonia: map['direccion_colonia'] as String?,
      direccionCp: map['direccion_cp'] as String?,
      direccionCiudad: map['direccion_ciudad'] as String?,
      direccionEstado: map['direccion_estado'] as String?,
      lat: map['lat'],
      lng: map['lng'],
      whatsapp: map['whatsapp'] as String?,
      minimoCompraDelivery: map['minimo_compra_delivery'],
      pickup: map['pickup'] as bool? ?? false,
      delivery: map['delivery'] as bool? ?? false,
      precioDelivery: map['precio_delivery'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}