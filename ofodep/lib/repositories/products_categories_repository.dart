import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsCategoriesRepository extends Repository<ProductsCategoryModel> {
  const ProductsCategoriesRepository();
  @override
  String get tableName => 'products_categories';

  @override
  String get select => '*, stores(name)';

  @override
  ProductsCategoryModel fromMap(Map<String, dynamic> map) =>
      ProductsCategoryModel.fromMap(map);

  @override
  Future<String?> create(ProductsCategoryModel model) async {
    model.position ??= await last(model.storeId) + 1;
    return super.create(model);
  }

  Future<bool> moveAfter({
    required String movingCategoryId,
    required String targetCategoryId,
  }) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'products_categories_move_afer',
        params: {
          'p_moving_category_id': movingCategoryId,
          'p_target_category_id': targetCategoryId,
        },
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> moveUp(String categoryId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'products_categories_move_up',
        params: {
          'p_category_id': categoryId,
        },
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  /// Mueve la categoría identificada por [categoryId] hacia abajo (intercambia con
  /// la categoría inmediatamente inferior dentro del mismo store).
  Future<bool> moveDown(String categoryId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'products_categories_move_down',
        params: {
          'p_category_id': categoryId,
        },
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  /// Retorna el último valor de posición (valor máximo del campo "position") para el store
  /// identificado por [storeId].
  Future<int> last(String storeId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'products_categories_last',
        params: {
          'p_store_id': storeId,
        },
      );
      return response;
    } catch (e) {
      return 0;
    }
  }
}
