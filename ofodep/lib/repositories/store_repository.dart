import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreRepository extends Repository<StoreModel> {
  @override
  String get tableName => 'stores';

  @override
  StoreModel fromMap(Map<String, dynamic> map) {
    return StoreModel.fromMap(map);
  }

  /// Obtiene una lista paginada de tiendas, aplicando búsqueda textual en las columnas
  /// name, address_street, address_state, address_city, address_colony, address_number,
  /// address_zipcode y whatsapp.
  @override
  Future<List<StoreModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    List<String>? searchColumns,
    String? orderBy,
    bool ascending = false,
  }) {
    // Si no se especifican columnas de búsqueda, se usan las predeterminadas para tiendas.
    final columns = searchColumns ??
        [
          'name',
          'address_street',
          'address_state',
          'address_city',
          'address_colony',
          'address_number',
          'address_zipcode',
          'whatsapp'
        ];

    return super.getPaginated(
      page: page,
      limit: limit,
      filter: filter,
      search: search,
      searchColumns: columns,
      orderBy: orderBy,
      ascending: ascending,
    );
  }
}
