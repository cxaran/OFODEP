import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/store_images_model.dart';
import 'package:ofodep/repositories/store_images_repository.dart';

class StoreImagesCubit extends CrudCubit<StoreImagesModel> {
  StoreImagesCubit({
    required super.id,
    StoreImagesRepository? storeImagesRepository,
  }) : super(
          repository: storeImagesRepository ?? StoreImagesRepository(),
        );

  @override
  Future<void> load({
    StoreImagesModel? model,
    StoreImagesModel? createModel,
  }) async {
    emit(CrudLoading<StoreImagesModel>());
    try {
      final model = await repository.getById(id);
      if (model != null) {
        emit(CrudLoaded<StoreImagesModel>(model));
      } else {
        emit(
          CrudCreate(
            editedModel: StoreImagesModel(
              id: '_',
              storeId: id,
              imgurClientId: '',
              imgurClientSecret: '',
            ),
          ),
        );
      }
    } catch (e) {
      emit(CrudError<StoreImagesModel>(e.toString()));
    }
  }
}
