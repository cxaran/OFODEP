import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/stores_info_list_cubit.dart';
import 'package:ofodep/models/store_info_model.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/preview_image.dart';

class AdminStoresPage extends StatelessWidget {
  const AdminStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListCubitStateHandler<StoreInfoModel, StoresInfoListCubit>(
        title: 'Comercios',
        createCubit: (context) => StoresInfoListCubit()
          ..updateSearchFields(
            ['name', 'country_code', 'timezone', 'subscription_type'],
          ),
        itemBuilder: (context, cubit, model, index) => ListTile(
          leading: PreviewImage.mini(imageUrl: model.logoUrl),
          title: Text(model.name),
          subtitle: Text(
            '${model.timezone} ${model.countryCode}\n'
            '${model.id}\n'
            '${model.subscriptionType.description.toUpperCase()}\n'
            'Expira el ${MaterialLocalizations.of(context).formatCompactDate(model.expirationDate!)}',
          ),
          onTap: () => context.push('/admin/store/${model.id}').then(
                (back) => back == true ? cubit.refresh() : null,
              ),
        ),
        filterSectionBuilder: (context, cubit, state) => CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: 'name',
                  label: Text('Nombre'),
                ),
                ButtonSegment(
                  value: 'created_at',
                  label: Text('Creación'),
                ),
                ButtonSegment(
                  value: 'expiration_date',
                  label: Text('Expiración'),
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
      ),
    );
  }
}
