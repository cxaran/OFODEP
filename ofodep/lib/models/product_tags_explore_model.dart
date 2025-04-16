import 'package:ofodep/models/abstract_model.dart';

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
  factory ProductTagsExploreModel.fromMap(Map<String, dynamic> map) {
    return ProductTagsExploreModel(
      tag: map['tag'],
      count: map['count'],
    );
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
