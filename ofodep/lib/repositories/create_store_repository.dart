import 'package:ofodep/models/create_store_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';

class CreateStoreRepository extends Repository<CreateStoreModel> {
  @override
  String get tableName => 'create_store';

  @override
  String get fieldId => 'auth_id';

  @override
  String? get rpc => 'create_store';

  @override
  CreateStoreModel fromMap(Map<String, dynamic> map) =>
      CreateStoreModel.fromMap(map);

  @override
  Future<String?> create(CreateStoreModel model) async {
    try {
      final response = await client.rpc(
        rpc!,
        params: model.toMap(),
      );

      if (response != null && response is String) {
        return response;
      }
      return null;
    } catch (e) {
      throw Exception('error(create): $e');
    }
  }
}
