import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/repositories/store_subscription_repository.dart';

class StoreSubscriptionCubit
    extends CrudCubit<StoreSubscriptionModel, StoreSubscriptionRepository> {
  StoreSubscriptionCubit({
    super.repository = const StoreSubscriptionRepository(),
    super.initialState,
  });
}
