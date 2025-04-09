import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/repositories/store_subscription_repository.dart';

class StoreSubscriptionsListCubit extends ListCubit<StoreSubscriptionModel> {
  StoreSubscriptionsListCubit({
    StoreSubscriptionRepository? storeSubscriptionRepository,
    super.limit,
  }) : super(
          initialState: const FilterState(),
          repository:
              storeSubscriptionRepository ?? StoreSubscriptionRepository(),
        );
}
