import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository extends Repository<ProductModel> {
  const ProductRepository();
  @override
  String get tableName => 'products';

  @override
  String get select => '*, stores(name), products_categories(name)';

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);

  @override
  Future<String?> create(ProductModel model) async {
    model.position ??= await productsLast(model.categoryId ?? '');
    return super.create(model);
  }

  /// Mueve el producto identificado por [productId] hacia arriba (intercambia con
  /// el producto inmediatamente superior dentro de la misma categoría y tienda).
  Future<bool> moveUp(String productId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'products_move_up',
        params: {'p_product_id': productId},
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  /// Mueve el producto identificado por [productId] hacia abajo (intercambia con
  /// el producto inmediatamente inferior dentro de la misma categoría y tienda).
  Future<bool> moveDown(String productId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'products_move_down',
        params: {'p_product_id': productId},
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  /// Retorna el último valor de posición (valor máximo del campo "position") para el store
  /// identificado por [categoryId].
  Future<int> productsLast(String categoryId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'products_last',
        params: {'p_category_id': categoryId},
      );
      return response;
    } catch (e) {
      return 0;
    }
  }
}
