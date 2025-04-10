import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/store_schedule_exceptions_list_cubit.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/message_page.dart';

class AdminStoreScheduleExceptionsPage extends StatelessWidget {
  final String? storeId;
  const AdminStoreScheduleExceptionsPage({
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
      body: ListCubitStateHandler(
        title: 'Horarios especiales',
        showSearchBar: false,
        createCubit: (context) => StoreScheduleExceptionsListCubit(
          storeId: storeId!,
        ),
        itemBuilder: (context, model, index) => ListTile(
          title: Text(
            MaterialLocalizations.of(context).formatCompactDate(
              model.date,
            ),
          ),
          subtitle: Text(
            '${model.openingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(model.openingTime!)}'
            ' - '
            '${model.closingTime == null ? '-' : MaterialLocalizations.of(context).formatTimeOfDay(model.closingTime!)}',
          ),
          onTap: () => context.push('/admin/schedule_exception/${model.id}'),
        ),
        filterSectionBuilder: (context, cubit, state) => CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: 'date',
                  label: Text('Fecha'),
                ),
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
        onAdd: (context, cubit) => context.push(
          '/admin/schedule_exception/create',
          extra: StoreScheduleExceptionModel(
            id: 'new',
            storeId: storeId!,
            date: DateTime.now().subtract(
              const Duration(days: 1),
            ),
          ),
        ),
      ),
    );
  }
}
