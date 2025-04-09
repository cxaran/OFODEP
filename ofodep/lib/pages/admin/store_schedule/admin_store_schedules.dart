import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/store_schedules_list_cubit.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/message_page.dart';

class AdminStoreSchedulesPage extends StatelessWidget {
  final String? storeId;
  const AdminStoreSchedulesPage({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return const MessagePage.error();
    }

    return Scaffold(
      body: ListCubitStateHandler(
        createCubit: (context) => StoreSchedulesListCubit(storeId: storeId!),
        itemBuilder: (context, model, index) => ListTile(
          title: Text(model.days.map(dayName).join(', ')),
          subtitle: Text(
            '${model.openingTime == null ? 'Hora de apertura no definida' : MaterialLocalizations.of(context).formatTimeOfDay(model.openingTime!)}'
            ' - '
            '${model.closingTime == null ? 'Hora de cierre no definida' : MaterialLocalizations.of(context).formatTimeOfDay(model.closingTime!)}',
          ),
          onTap: () => context.push('/admin/schedule/${model.id}'),
        ),
      ),
    );
  }
}
