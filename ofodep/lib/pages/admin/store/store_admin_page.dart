import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_cubit.dart';
import 'package:ofodep/const.dart';
import 'package:ofodep/models/country_timezone.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/repositories/store_images_repository.dart';
import 'package:ofodep/repositories/store_subscription_repository.dart';
import 'package:ofodep/widgets/admin_image.dart';
import 'package:ofodep/widgets/container_page.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/location_picker.dart';
import 'package:ofodep/widgets/preview_image.dart';
import 'package:ofodep/widgets/zone_polygon.dart';

class StoreAdminPage extends StatelessWidget {
  final String? storeId;

  const StoreAdminPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return const MessagePage.error();
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Administrar comercio'),
      // ),
      body: ContainerPage.zero(
        child: CrudStateHandler<StoreModel>(
          createCubit: (context) => StoreCubit(id: storeId!)..load(),
          loadedBuilder: loadedBuilder,
          editingBuilder: editingBuilder,
        ),
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    CrudCubit<StoreModel> cubit,
    CrudLoaded<StoreModel> state,
  ) {
    if (cubit is StoreCubit) {
      StoreModel store = state.model;
      return CustomListView(
        title: 'Configura tu comercio',
        children: [
          ListTile(
            leading: PreviewImage.mini(imageUrl: store.logoUrl),
            title: Text(store.name),
            onTap: () =>
                cubit.startEditing(editSection: StoreEditSection.general),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text('Datos de contacto'),
            subtitle: Text(
              [
                store.addressStreet,
                store.addressNumber,
                store.addressColony,
                store.addressZipcode,
                store.addressCity,
                store.addressState
              ].where((e) => e != null && e.isNotEmpty).join(', '),
            ),
            onTap: () => cubit.startEditing(
              editSection: StoreEditSection.contact,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pin_drop),
            title: Text('Ubicación'),
            onTap: () => cubit.startEditing(
              editSection: StoreEditSection.coordinates,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: Text('Zona de cobertura'),
            onTap: () => cubit.startEditing(
              editSection: StoreEditSection.geom,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delivery_dining),
            title: Text('Configuración de entregas'),
            onTap: () => cubit.startEditing(
              editSection: StoreEditSection.delivery,
            ),
          ),
          const Divider(),
          ListTile(
            leading: FutureBuilder(
              future: StoreImagesRepository().getById(store.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!snapshot.hasData) {
                    return const Badge(
                      label: Text('1'),
                      child: Icon(Icons.image),
                    );
                  }
                }
                return const Icon(Icons.image);
              },
            ),
            title: Text('Configuración de imagenes'),
            onTap: () => context.push('/admin/store_images/${store.id}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Horarios'),
            onTap: () => context.push('/admin/schedules/${store.id}'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Horarios especiales'),
            onTap: () => context.push('/admin/schedule_exceptions/${store.id}'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Productos'),
            onTap: () => context.push('/admin/products/${store.id}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Pedidos'),
            onTap: () => context.push('/admin/orders?store=${store.id}'),
          ),
          const Divider(),
          ListTile(
            leading: FutureBuilder(
              future: StoreSubscriptionRepository().getById(store.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data?.expirationDate.isBefore(DateTime.now()) ??
                      false) {
                    return const Badge(
                      label: Text('1'),
                      child: Icon(Icons.sell),
                    );
                  }
                }
                return const Icon(Icons.sell);
              },
            ),
            title: const Text('Suscripción'),
            onTap: () => context.push('/admin/subscription/${store.id}'),
          ),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text('Administradores del comercio'),
            onTap: () => context.push('/admin/store_admins/${store.id}'),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  /// Renderiza la página de la tienda.
  /// Si el estado es de edición (StoreCrudEditing) muestra el formulario según la sección,
  /// de lo contrario muestra un menú de secciones.
  Widget editingBuilder(
    BuildContext context,
    CrudCubit<StoreModel> cubit,
    CrudEditing<StoreModel> state,
  ) {
    if (state is StoreCrudEditing && cubit is StoreCubit) {
      switch (state.editSection) {
        case StoreEditSection.general:
          return _buildGeneralSection(cubit, state);
        case StoreEditSection.contact:
          return _buildContactSection(cubit, state);
        case StoreEditSection.coordinates:
          return _buildCoordinatesSection(cubit, state);
        case StoreEditSection.geom:
          return _buildGeomSection(cubit, state);
        case StoreEditSection.delivery:
          return _buildDeliverySection(cubit, state);
      }
    }
    return Container();
  }

  /// Sección general: nombre y logo de la tienda.
  Widget _buildGeneralSection(
    StoreCubit cubit,
    StoreCrudEditing state,
  ) {
    final formKey = GlobalKey<FormState>();
    final edited = state.editedModel;
    return CustomListView(
      formKey: formKey,
      title: 'Logotipo del comercio',
      onBack: state.isSubmitting ? null : () => cubit.cancelEditing(),
      actions: [
        ElevatedButton.icon(
          onPressed: state.editMode ? () => submit(formKey, cubit) : null,
          icon: const Icon(Icons.check),
          label: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Guardar"),
        ),
      ],
      children: [
        const Text(
          'Con este logotipo y nombre aparecerá en la página de tu tienda en el portal.',
        ),
        Divider(),
        AdminImage(
          clientId: null,
          imageUrl: edited.logoUrl,
          onImageUploaded: (url) {
            cubit.updateEditingState(
              (model) => model.copyWith(logoUrl: url),
            );
          },
        ),
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(
            icon: Icon(Icons.storefront),
            labelText: "Nombre del comercio",
            hintText: "Comercio",
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditingState(
            (model) => model.copyWith(
              name: value,
            ),
          ),
        ),
      ],
    );
  }

  /// Sección de contacto y dirección.
  Widget _buildContactSection(StoreCubit cubit, StoreCrudEditing state) {
    final formKey = GlobalKey<FormState>();
    final edited = state.editedModel;
    return CustomListView(
      formKey: formKey,
      title: 'Datos de contacto',
      onBack: state.isSubmitting ? null : () => cubit.cancelEditing(),
      actions: [
        ElevatedButton.icon(
          onPressed: state.editMode ? () => submit(formKey, cubit) : null,
          icon: const Icon(Icons.check),
          label: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Guardar"),
        ),
      ],
      children: [
        const Text(
          "Tu dirección y contacto se mostrarán en tu tienda y se utilizarán para validar los horarios de entrega segun tu zona horaria.",
        ),
        Divider(),
        TextFormField(
          initialValue: edited.addressStreet,
          decoration: const InputDecoration(
            labelText: "Calle",
          ),
          validator: validate,
          onChanged: (value) {
            cubit.updateEditingState(
              (model) => model.copyWith(addressStreet: value),
            );
          },
        ),
        TextFormField(
          initialValue: edited.addressNumber,
          decoration: const InputDecoration(
            labelText: "Numero",
          ),
          validator: validate,
          onChanged: (value) {
            cubit.updateEditingState(
              (model) => model.copyWith(addressNumber: value),
            );
          },
        ),
        TextFormField(
          initialValue: edited.addressColony,
          decoration: const InputDecoration(
            labelText: "Colonia o barrio",
          ),
          validator: validate,
          onChanged: (value) {
            cubit.updateEditingState(
              (model) => model.copyWith(addressColony: value),
            );
          },
        ),
        TextFormField(
          initialValue: edited.addressZipcode,
          decoration: const InputDecoration(
            labelText: "Código postal",
          ),
          validator: validate,
          onChanged: (value) {
            cubit.updateEditingState(
              (model) => model.copyWith(addressZipcode: value),
            );
          },
        ),
        TextFormField(
          initialValue: edited.addressCity,
          decoration: const InputDecoration(
            labelText: "Ciudad o municipio",
          ),
          validator: validate,
          onChanged: (value) {
            cubit.updateEditingState(
              (model) => model.copyWith(addressCity: value),
            );
          },
        ),
        TextFormField(
          initialValue: edited.addressState,
          decoration: const InputDecoration(
            labelText: "Estado",
          ),
          validator: validate,
          onChanged: (value) {
            cubit.updateEditingState(
              (model) => model.copyWith(addressState: value),
            );
          },
        ),
        DropdownButtonFormField<CountryTimezone>(
          decoration: const InputDecoration(
            labelText: "Pais y zona horaria",
          ),
          value: edited.countryCode == '' || edited.timezone == ''
              ? null
              : CountryTimezone(
                  country: edited.countryCode ?? '',
                  timezone: edited.timezone ?? '',
                ),
          items: timeZonesLatAm
              .map((tz) => DropdownMenuItem<CountryTimezone>(
                    value: tz,
                    child: Text(
                        '${tz.timezone.replaceAll('America/', '')} (${tz.country})'),
                  ))
              .toList(),
          onChanged: (tz) {
            cubit.updateEditingState(
              (model) => model.copyWith(
                countryCode: tz?.country,
                timezone: tz?.timezone,
              ),
            );
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecciona un zona horaria';
            }
            return null;
          },
        ),
        TextFormField(
          initialValue: edited.whatsapp,
          decoration: const InputDecoration(labelText: "WhatsApp"),
          validator: validate,
          onChanged: (value) {
            cubit.updateEditingState(
              (model) => model.copyWith(whatsapp: value),
            );
          },
        ),
      ],
    );
  }

  /// Sección de coordenadas geográficas.
  Widget _buildCoordinatesSection(StoreCubit cubit, StoreCrudEditing state) {
    final edited = state.editedModel;

    if (edited.countryCode == null || edited.countryCode!.isEmpty) {
      return const Center(
        child: Text("country_code_null"),
      );
    }
    return Column(
      children: [
        Expanded(
          child: LocationPicker(
            initialLatitude: edited.lat?.toDouble(),
            initialLongitude: edited.lng?.toDouble(),
            onLocationChanged: (p0) => cubit.updateEditingState(
              (model) => model.copyWith(
                lat: p0.latitude,
                lng: p0.longitude,
                geom: {
                  'type': 'Polygon',
                  'crs': {
                    'type': 'name',
                    'properties': {'name': 'EPSG:4326'},
                  },
                  'coordinates': [],
                },
              ),
            ),
          ),
        ),
        Text('Lat: ${edited.lat} Lng: ${edited.lng}'),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => cubit.submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting ? null : () => cubit.cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }

  /// Sección de áreas de cobertura (zipcodes).
  Widget _buildGeomSection(StoreCubit cubit, StoreCrudEditing state) {
    if (state.editedModel.lat == null || state.editedModel.lng == null) {
      return const Center(
        child: Text("coordinates_null"),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ZonePolygon(
            geom: state.editedModel.geom,
            centerLatitude: state.editedModel.lat!.toDouble(),
            centerLongitude: state.editedModel.lng!.toDouble(),
            onGeomChanged: (geom) {
              cubit.updateEditingState(
                (model) => model.copyWith(geom: geom),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => cubit.submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting ? null : () => cubit.cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }

  /// Sección de configuración de delivery.
  Widget _buildDeliverySection(StoreCubit cubit, StoreCrudEditing state) {
    final edited = state.editedModel;
    return ListView(
      children: [
        const Text("Edit delivery settings"),
        TextFormField(
          initialValue: edited.deliveryMinimumOrder?.toString() ?? "",
          decoration: const InputDecoration(
            labelText: "Minimum order for delivery",
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? minOrder = num.tryParse(value);
            cubit.updateEditingState(
                (model) => model.copyWith(deliveryMinimumOrder: minOrder));
          },
        ),
        SwitchListTile(
          title: const Text("Pickup"),
          value: edited.pickup,
          onChanged: (value) {
            cubit.updateEditingState((model) => model.copyWith(pickup: value));
          },
        ),
        SwitchListTile(
          title: const Text("Delivery"),
          value: edited.delivery,
          onChanged: (value) {
            cubit
                .updateEditingState((model) => model.copyWith(delivery: value));
          },
        ),
        TextFormField(
          initialValue: edited.deliveryPrice?.toString() ?? "",
          decoration: const InputDecoration(labelText: "Delivery price"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? price = num.tryParse(value);
            cubit.updateEditingState(
                (model) => model.copyWith(deliveryPrice: price));
          },
        ),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => cubit.submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting ? null : () => cubit.cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }
}
