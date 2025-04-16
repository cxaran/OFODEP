import 'package:ofodep/models/product_tags_explore_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductTagsExploreRepository extends Repository<ProductTagsExploreModel> {
  const ProductTagsExploreRepository();

  @override
  String get tableName => 'product_tags_explore';

  @override
  String get select => '*';

  @override
  String get rpc => 'product_tags_explore';

  @override
  ProductTagsExploreModel fromMap(Map<String, dynamic> map) {
    return ProductTagsExploreModel.fromMap(map);
  }

  Future<List<ProductTagsExploreModel>> getProductTags({
    String? countryCode,
    double? userLat,
    double? userLng,
    int? tagsLimit,
  }) async {
    try {
      final response = await Supabase.instance.client.rpc(
        rpc,
        params: {
          'country_code': countryCode,
          'user_lat': userLat,
          'user_lng': userLng,
          'tags_limit': tagsLimit,
        },
      ).select(select);
      return response.map((data) => fromMap(data)).toList();
    } catch (e) {
      throw Exception('error(getProductTags): $e');
    }
  }
}
