import 'package:ofodep/models/store_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreRepository {
  static const String tableName = 'stores';

  const StoreRepository();

  /// Obtiene una tienda (store) por su id.
  Future<StoreModel?> getStore(String storeId) async {
    try {
      final data = await Supabase.instance.client
          .from(tableName)
          .select()
          .eq('id', storeId)
          .maybeSingle();

      if (data == null) return null;
      return StoreModel.fromMap(data);
    } catch (e) {
      throw Exception('Error al obtener tienda: $e');
    }
  }

  /// Agrega una tienda.
  Future<StoreModel?> createStore({
    required String name,
    String? logoUrl,
    String? addressStreet,
    String? addressNumber,
    String? addressColony,
    String? addressZipcode,
    String? addressCity,
    String? addressState,
    num? lat,
    num? lng,
    List<String>? zipcodes,
    String? whatsapp,
    num? deliveryMinimumOrder,
    bool pickup = false,
    bool delivery = false,
    num? deliveryPrice,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from(tableName)
          .insert({
            'name': name,
            'logo_url': logoUrl,
            'address_street': addressStreet,
            'address_number': addressNumber,
            'address_colony': addressColony,
            'address_zipcode': addressZipcode,
            'address_city': addressCity,
            'address_state': addressState,
            'lat': lat,
            'lng': lng,
            'zipcodes': zipcodes,
            'whatsapp': whatsapp,
            'delivery_minimum_order': deliveryMinimumOrder,
            'pickup': pickup,
            'delivery': delivery,
            'delivery_price': deliveryPrice,
          })
          .select('id')
          .maybeSingle();

      if (response == null) return null;

      return StoreModel.fromMap(response);
    } catch (e) {
      throw Exception('Error al agregar tienda: $e');
    }
  }

  /// Actualiza una tienda.
  Future<bool> updateStore(
    String storeId, {
    String? name,
    String? logoUrl,
    String? addressStreet,
    String? addressNumber,
    String? addressColony,
    String? addressZipcode,
    String? addressCity,
    String? addressState,
    num? lat,
    num? lng,
    List<String>? zipcodes,
    String? whatsapp,
    num? deliveryMinimumOrder,
    bool? pickup = false,
    bool? delivery = false,
    num? deliveryPrice,
    String? imgurClientId,
    String? imgurClientSecret,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (logoUrl != null) updates['logo_url'] = logoUrl;
      if (addressStreet != null) updates['address_street'] = addressStreet;
      if (addressNumber != null) updates['address_number'] = addressNumber;
      if (addressColony != null) updates['address_colony'] = addressColony;
      if (addressZipcode != null) updates['address_zipcode'] = addressZipcode;
      if (addressCity != null) updates['address_city'] = addressCity;
      if (addressState != null) updates['address_state'] = addressState;
      if (lat != null) updates['lat'] = lat;
      if (lng != null) updates['lng'] = lng;

      updates['zipcodes'] = zipcodes ?? [];

      if (whatsapp != null) updates['whatsapp'] = whatsapp;
      if (deliveryMinimumOrder != null) {
        updates['delivery_minimum_order'] = deliveryMinimumOrder;
      }
      if (pickup != null) updates['pickup'] = pickup;
      if (delivery != null) updates['delivery'] = delivery;
      if (deliveryPrice != null) updates['delivery_price'] = deliveryPrice;
      if (imgurClientId != null) updates['imgur_client_id'] = imgurClientId;
      if (imgurClientSecret != null) {
        updates['imgur_client_secret'] = imgurClientSecret;
      }

      final response = await Supabase.instance.client
          .from(tableName)
          .update(updates)
          .eq('id', storeId)
          .select('id');

      if (response.isEmpty) return false;
      return true;
    } on Exception catch (e) {
      throw Exception('Error al actualizar tienda: $e');
    }
  }

  /// Obtiene una lista paginada de tiendas con filtros, búsqueda y ordenamiento.
  Future<List<StoreModel>> getStores({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) async {
    final supabase = Supabase.instance.client;

    // Construir la consulta básica
    var query = supabase.from(tableName).select('*');

    // Aplicar filtros personalizados
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

    // Aplicar búsqueda textual (en varias columnas)
    if (search != null && search.isNotEmpty) {
      String searchString = '%$search%';
      // Combinar la búsqueda con OR en las columnas relevantes
      // Nota: La forma de combinar múltiples OR con supabase.dart puede variar,
      // aquí simplemente se ejemplifica un uso básico.
      query = query.or(
          'name.ilike.$searchString,address_street.ilike.$searchString,address_state.ilike.$searchString,address_city.ilike.$searchString,address_colony.ilike.$searchString,address_number.ilike.$searchString,address_zipcode.ilike.$searchString,whatsapp.ilike.$searchString');
    }

    // Ordenamiento
    var paginationQuery = (orderBy != null && orderBy.isNotEmpty)
        ? query.order(orderBy, ascending: ascending)
        : query.order('created_at', ascending: false);

    // Paginación
    paginationQuery = paginationQuery.range(
      (page - 1) * limit,
      (page * limit) - 1,
    );

    try {
      // Ejecutar la consulta
      final List<dynamic> response = await paginationQuery;
      // Convertir cada registro en una instancia de StoreModel
      return response.map((data) => StoreModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error al obtener tiendas: $e');
    }
  }
}
