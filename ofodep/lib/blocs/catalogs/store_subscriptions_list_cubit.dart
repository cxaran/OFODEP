import 'package:ofodep/blocs/catalogs/abstract_list_cubit.dart';
import 'package:ofodep/blocs/catalogs/filter_state.dart';
import 'package:ofodep/models/store_subscription_model.dart';
import 'package:ofodep/repositories/store_subscription_repository.dart';

class StoreSubscriptionsListCubit
    extends ListCubit<StoreSubscriptionModel, BasicListFilterState> {
  StoreSubscriptionsListCubit({
    StoreSubscriptionRepository? storeSubscriptionRepository,
    super.limit,
  }) : super(
          initialState: const BasicListFilterState(),
          repository:
              storeSubscriptionRepository ?? StoreSubscriptionRepository(),
        );
}
