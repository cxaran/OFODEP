import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/repositories/store_subscription_repository.dart';

class StoreSubscriptionsListCubit
    extends ListCubit<StoreSubscriptionModel, StoreSubscriptionRepository> {
  StoreSubscriptionsListCubit({
    super.repository = const StoreSubscriptionRepository(),
    super.initialState,
  });
}
