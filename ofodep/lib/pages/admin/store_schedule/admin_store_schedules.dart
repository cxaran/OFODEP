import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/store_schedules_list_cubit.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
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
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: ListCubitStateHandler<StoreScheduleModel, StoreSchedulesListCubit>(
        title: 'Horarios',
        createCubit: (context) => StoreSchedulesListCubit(storeId: storeId!),
        showSearchBar: false,
        itemBuilder: (context, cubit, model, index) => ListTile(
          title: Text(model.days.map(dayName).join(', ')),
          subtitle: Text(
            '${model.openingTime == null ? 'Hora de apertura no definida' : MaterialLocalizations.of(context).formatTimeOfDay(model.openingTime!)}'
            ' - '
            '${model.closingTime == null ? 'Hora de cierre no definida' : MaterialLocalizations.of(context).formatTimeOfDay(model.closingTime!)}',
          ),
          onTap: () => context.push('/admin/schedule/${model.id}'),
        ),
        filterSectionBuilder: (context, cubit, state) => CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: 'opening_time',
                  label: Text('Apertura'),
                ),
                ButtonSegment(
                  value: 'closing_time',
                  label: Text('Cierre'),
                ),
              ],
              selected: {state.orderBy},
              onSelectionChanged: (orderBy) => cubit.updateOrdering(
                orderBy: orderBy.first,
              ),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Ascendente')),
                ButtonSegment(value: false, label: Text('Descendente')),
              ],
              selected: {state.ascending},
              onSelectionChanged: (ascending) => cubit.updateOrdering(
                ascending: ascending.first,
              ),
            ),
          ],
        ),
        onAdd: (context, cubit) => pageNewModel(
          context,
          '/admin/schedule',
          StoreScheduleModel(
            storeId: storeId!,
            days: [],
          ),
        ),
      ),
    );
  }
}
