import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/store_admins_list_cubit.dart';
import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';

class AdminStoreAdminsPage extends StatelessWidget {
  final String? storeId;
  const AdminStoreAdminsPage({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListCubitStateHandler<StoreAdminModel, StoreAdminsListCubit>(
        title: 'Administradores de comercio',
        createCubit: (context) => StoreAdminsListCubit(storeId: storeId)
          ..updateSearchFields(
            ['contact_name', 'contact_email'],
          ),
        itemBuilder: (context, cubit, model, index) => ListTile(
          title: Text(model.contactName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.contactEmail),
              if (storeId == null) Text(model.storeName ?? ''),
            ],
          ),
          trailing: model.isPrimaryContact ?? false
              ? const Icon(Icons.admin_panel_settings)
              : null,
          onTap: () => context.push('/admin/store_admin/${model.id}').then(
                (back) => back == true ? cubit.refresh() : null,
              ),
        ),
        filterSectionBuilder: (context, cubit, state) => CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: 'contact_name',
                  label: Text('Nombre'),
                ),
                ButtonSegment(
                  value: 'ontact_email',
                  label: Text('Correo'),
                ),
                ButtonSegment(
                  value: 'is_primary_contact',
                  label: Text('Principal'),
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
        onAdd: storeId == null
            ? null
            : (context, cubit) => pageNewModel(
                  context,
                  '/admin/store_admin',
                  StoreAdminModel(
                    storeId: storeId!,
                    userId: '',
                    contactName: '',
                    contactEmail: '',
                    contactPhone: '',
                    isPrimaryContact: false,
                  ),
                ).then(
                  (back) => back == true ? cubit.refresh() : null,
                ),
      ),
    );
  }
}
