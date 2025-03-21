import 'package:ofodep/models/comercio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommerceRepository {
  static const String tableName = 'comercios';

  const CommerceRepository();

  /// Obtiene un comercio por su id.
  Future<Comercio?> getCommerce(String comercioId) async {
    try {
      final data = await Supabase.instance.client
          .from(tableName)
          .select()
          .eq('id', comercioId)
          .maybeSingle();

      if (data == null) return null;
      return Comercio.fromMap(data);
    } catch (e) {
      throw Exception('Error al obtener comercio: $e');
    }
  }

  /// Agrega un comercio.
  Future<Comercio?> createCommerce({
    required String nombre,
    String? logoUrl,
    String? direccionCalle,
    String? direccionNumero,
    String? direccionColonia,
    String? direccionCp,
    String? direccionCiudad,
    String? direccionEstado,
    num? lat,
    num? lng,
    List<String>? codigosPostales,
    String? whatsapp,
    num? minimoCompraDelivery,
    bool pickup = false,
    bool delivery = false,
    num? precioDelivery,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from(tableName)
          .insert({
            'nombre': nombre,
            'logo_url': logoUrl,
            'direccion_calle': direccionCalle,
            'direccion_numero': direccionNumero,
            'direccion_colonia': direccionColonia,
            'direccion_cp': direccionCp,
            'direccion_ciudad': direccionCiudad,
            'direccion_estado': direccionEstado,
            'lat': lat,
            'lng': lng,
            'codigos_postales': codigosPostales,
            'whatsapp': whatsapp,
            'minimo_compra_delivery': minimoCompraDelivery,
            'pickup': pickup,
            'delivery': delivery,
            'precio_delivery': precioDelivery,
          })
          .select('id')
          .maybeSingle();

      if (response == null) return null;

      return Comercio.fromMap(response);
    } catch (e) {
      throw Exception('Error al agregar comercio: $e');
    }
  }

  /// Actualiza un comercio.
  Future<bool> updateCommerce(
    String comercioId, {
    String? nombre,
    String? logoUrl,
    String? direccionCalle,
    String? direccionNumero,
    String? direccionColonia,
    String? direccionCp,
    String? direccionCiudad,
    String? direccionEstado,
    num? lat,
    num? lng,
    List<String>? codigosPostales,
    String? whatsapp,
    num? minimoCompraDelivery,
    bool? pickup = false,
    bool? delivery = false,
    num? precioDelivery,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (nombre != null) updates['nombre'] = nombre;
      if (logoUrl != null) updates['logo_url'] = logoUrl;
      if (direccionCalle != null) updates['direccion_calle'] = direccionCalle;
      if (direccionNumero != null) {
        updates['direccion_numero'] = direccionNumero;
      }
      if (direccionColonia != null) {
        updates['direccion_colonia'] = direccionColonia;
      }
      if (direccionCp != null) updates['direccion_cp'] = direccionCp;
      if (direccionCiudad != null) {
        updates['direccion_ciudad'] = direccionCiudad;
      }
      if (direccionEstado != null) {
        updates['direccion_estado'] = direccionEstado;
      }
      if (lat != null) updates['lat'] = lat;
      if (lng != null) updates['lng'] = lng;
      if (codigosPostales != null) {
        updates['codigos_postales'] = codigosPostales;
      }
      if (whatsapp != null) updates['whatsapp'] = whatsapp;
      if (minimoCompraDelivery != null) {
        updates['minimo_compra_delivery'] = minimoCompraDelivery;
      }
      if (pickup != null) updates['pickup'] = pickup;
      if (delivery != null) updates['delivery'] = delivery;
      if (precioDelivery != null) updates['precio_delivery'] = precioDelivery;

      final response = await Supabase.instance.client
          .from(tableName)
          .update(updates)
          .eq('id', comercioId)
          .select('id');

      if (response.isEmpty) return false;
      return true;
    } on Exception catch (e) {
      throw Exception('Error al actualizar comercio: $e');
    }
  }

  /// Obtiene una lista paginada de comercios con filtros, búsqueda y ordenamiento.
  Future<List<Comercio>> getCommerces({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) async {
    final supabase = Supabase.instance.client;

    // Construir la consulta básica.
    var query = supabase.from(tableName).select('*');

    // Aplicar filtros personalizados.
    if (filter != null) {
      if (filter.containsKey('created_at_gte')) {
        query = query.gte('created_at', filter['created_at_gte']);
      }
      if (filter.containsKey('created_at_lte')) {
        query = query.lte('created_at', filter['created_at_lte']);
      }
      if (filter.containsKey('updated_at_gte')) {
        query = query.gte('updated_at', filter['updated_at_gte']);
      }
      if (filter.containsKey('updated_at_lte')) {
        query = query.lte('updated_at', filter['updated_at_lte']);
      }
    }

    // Aplicar búsqueda textual (en nombre y descripción).
    if (search != null && search.isNotEmpty) {
      String searchString = '%$search%';
      for (var key in [
        'nombre',
        'direccion_calle',
        'direccion_estado',
        'direccion_ciudad',
        'direccion_colonia',
        'direccion_numero',
        'direccion_cp',
        'whatsapp'
      ]) {
        query = query.or('$key.ilike.$searchString');
      }
    }

    // Ordenamiento.
    var paginationQuery = (orderBy != null && orderBy.isNotEmpty)
        ? query.order(orderBy, ascending: ascending)
        : query.order('created_at', ascending: false);

    // Paginación.
    paginationQuery = paginationQuery.range(
      (page - 1) * limit,
      (page * limit) - 1,
    );

    try {
      // Ejecutar la consulta.
      final List<dynamic> response = await paginationQuery;
      // Convertir cada registro en una instancia de Comercio.
      return response.map((data) => Comercio.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error al obtener comercios: $e');
    }
  }
}
