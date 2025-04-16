import 'package:ofodep/models/product_explore_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductExploreRepository extends Repository<ProductExploreModel> {
  const ProductExploreRepository();

  @override
  String get tableName => 'product_explore';

  @override
  String get select => '*';

  @override
  String get fieldId => 'id';

  @override
  String get rpc => 'product_explore';

  @override
  ProductExploreModel fromMap(Map<String, dynamic> map) {
    return ProductExploreModel.fromMap(map);
  }

  Future<List<ProductExploreModel>> getProducts({
    required ProductExploreParams params,
    required int page,
  }) async {
    print(params.toMap());
    try {
      final response = await Supabase.instance.client
          .rpc(
            rpc,
            params: params.copyWith(page: page).toMap(),
          )
          .select(select);
      return response.map((data) => fromMap(data)).toList();
    } catch (e) {
      throw Exception('error(getProducts): $e');
    }
  }
}
