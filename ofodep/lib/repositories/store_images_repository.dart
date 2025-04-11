import 'package:ofodep/models/store_images_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class StoreImagesRepository extends Repository<StoreImagesModel> {
  const StoreImagesRepository();
  @override
  String get tableName => 'store_images';

  @override
  String get fieldId => 'store_id';

  @override
  StoreImagesModel fromMap(Map<String, dynamic> map) =>
      StoreImagesModel.fromMap(map);
}
