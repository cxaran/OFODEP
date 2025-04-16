import 'package:ofodep/models/abstract_model.dart';
import 'package:ofodep/models/abstract_params.dart';

class ProductTagsExploreParams extends ParamsComponent {
  final String countryCode;
  final double userLat;
  final double userLng;
  final double maxDistance;
  final int tagsLimit;

  ProductTagsExploreParams({
    required this.countryCode,
    required this.userLat,
    required this.userLng,
    required this.maxDistance,
    this.tagsLimit = 10,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'country_code': countryCode,
      'user_lat': userLat,
      'user_lng': userLng,
      'max_distance': maxDistance,
      'tags_limit': tagsLimit,
    };
  }

  @override
  ProductTagsExploreParams copyWith({String? id}) {
    return ProductTagsExploreParams(
      countryCode: countryCode,
      userLat: userLat,
      userLng: userLng,
      maxDistance: maxDistance,
      tagsLimit: tagsLimit,
    );
  }
}

class ProductTagsExploreModel extends ModelComponent {
  final String tag;
  final int count;

  ProductTagsExploreModel({
    required this.tag,
    required this.count,
  });

  @override
  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      'tag': tag,
      'count': count,
    };
  }

  @override
  ProductTagsExploreModel copyWith({
    String? id,
    String? tag,
    int? count,
  }) {
    return ProductTagsExploreModel(
      tag: tag ?? this.tag,
      count: count ?? this.count,
    );
  }

  @override
  String toString() => 'ProductTagsExploreModel(id: $id, '
      'tag: $tag, '
      'count: $count, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
