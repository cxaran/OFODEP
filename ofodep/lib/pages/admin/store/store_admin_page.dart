import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_cubit.dart';
import 'package:ofodep/utils/constants.dart';
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

  StoreAdminPage({super.key, required this.storeId});

  final formGeneralKey = GlobalKey<FormState>();

  final formContactKey = GlobalKey<FormState>();

  final formDeliveryKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }
    return Scaffold(
      body: ContainerPage.zero(
        child: CrudStateHandler<StoreModel, StoreCubit>(
          createCubit: (context) => StoreCubit()..load(storeId!),
          loadedBuilder: loadedBuilder,
          editingBuilder: editingBuilder,
        ),
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    StoreCubit cubit,
    CrudLoaded<StoreModel> state,
  ) {
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
          leading: const Icon(Icons.shopping_bag),
          title: const Text('Pedidos'),
          onTap: () => context.push('/admin/orders?store=${store.id}'),
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
          leading: store.lat == null || store.lng == null
              ? const Badge(
                  label: Text('1'),
                  child: Icon(Icons.pin_drop),
                )
              : const Icon(Icons.pin_drop),
          title: Text('Ubicación'),
          onTap: () => cubit.startEditing(
            editSection: StoreEditSection.coordinates,
          ),
        ),
        ListTile(
          leading: store.geom == null || store.geom!['coordinates'].isEmpty
              ? const Badge(
                  label: Text('1'),
                  child: Icon(Icons.map),
                )
              : const Icon(Icons.map),
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
        const Divider(),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Categorías de productos'),
          onTap: () => context.push('/admin/products_categories/${store.id}'),
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: const Text('Productos'),
          onTap: () => context.push('/admin/products/${store.id}'),
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

  /// Renderiza la página de la tienda.
  /// Si el estado es de edición (StoreCrudEditing) muestra el formulario según la sección,
  /// de lo contrario muestra un menú de secciones.
  Widget editingBuilder(
    BuildContext context,
    StoreCubit cubit,
    CrudEditing<StoreModel> state,
  ) {
    if (state is StoreCrudEditing) {
      switch (state.editSection) {
        case StoreEditSection.general:
          return buildGeneralSection(cubit, state);
        case StoreEditSection.contact:
          return buildContactSection(cubit, state);
        case StoreEditSection.coordinates:
          return buildCoordinatesSection(cubit, state);
        case StoreEditSection.geom:
          return buildGeomSection(cubit, state);
        case StoreEditSection.delivery:
          return buildDeliverySection(cubit, state);
      }
    }
    return Container();
  }

  /// Sección general: nombre y logo de la tienda.
  Widget buildGeneralSection(
    StoreCubit cubit,
    StoreCrudEditing state,
  ) {
    final edited = state.editedModel;
    return CustomListView(
      formKey: formGeneralKey,
      title: 'Logotipo del comercio',
      isLoading: state.isSubmitting,
      editMode: state.editMode,
      onSave: () => submit(formGeneralKey, cubit),
      onBack: cubit.cancelEditing,
      children: [
        const Text(
          'Con este logotipo y nombre aparecerá en la página de tu tienda en el portal.',
        ),
        Divider(),
        AdminImage(
          clientId: null,
          imageUrl: edited.logoUrl,
          onImageUploaded: (url) {
            cubit.updateEditedModel(
              (model) => model.copyWith(logoUrl: url),
            );
          },
        ),
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(
            icon: Icon(Icons.storefront),
            labelText: "Nombre del comercio",
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(
              name: value,
            ),
          ),
        ),
      ],
    );
  }

  /// Sección de contacto y dirección.
  Widget buildContactSection(StoreCubit cubit, StoreCrudEditing state) {
    final edited = state.editedModel;
    return CustomListView(
      formKey: formContactKey,
      title: 'Datos de contacto',
      isLoading: state.isSubmitting,
      editMode: state.editMode,
      onSave: () => submit(formContactKey, cubit),
      onBack: cubit.cancelEditing,
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
            cubit.updateEditedModel(
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
            cubit.updateEditedModel(
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
            cubit.updateEditedModel(
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
            cubit.updateEditedModel(
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
            cubit.updateEditedModel(
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
            cubit.updateEditedModel(
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
            cubit.updateEditedModel(
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
            cubit.updateEditedModel(
              (model) => model.copyWith(whatsapp: value),
            );
          },
        ),
      ],
    );
  }

  /// Sección de coordenadas geográficas.
  Widget buildCoordinatesSection(StoreCubit cubit, StoreCrudEditing state) {
    final edited = state.editedModel;
    if (edited.countryCode == null || edited.timezone == null) {
      return MessagePage.warning(
        "El pais y zona horaria no están definidos.",
        onBack: cubit.cancelEditing,
      );
    }
    return LocationPicker(
      title: "Ubicación de tu comercio",
      onBack: cubit.cancelEditing,
      onSave: state.editMode ? () => cubit.submit() : null,
      initialLatitude: edited.lat?.toDouble(),
      initialLongitude: edited.lng?.toDouble(),
      onLocationChanged: (p0) => cubit.updateEditedModel(
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
    );
  }

  /// Sección de áreas de cobertura
  Widget buildGeomSection(StoreCubit cubit, StoreCrudEditing state) {
    final edited = state.editedModel;
    if (edited.lat == null || edited.lng == null) {
      return MessagePage.warning(
        "La ubicación no está definida.",
        onBack: cubit.cancelEditing,
      );
    }
    return ZonePolygon(
      title: "Área de cobertura del comercio",
      onBack: cubit.cancelEditing,
      onSave: state.editMode ? () => cubit.submit() : null,
      geom: state.editedModel.geom,
      centerLatitude: edited.lat!.toDouble(),
      centerLongitude: edited.lng!.toDouble(),
      onGeomChanged: (geom) {
        cubit.updateEditedModel(
          (model) => model.copyWith(geom: geom),
        );
      },
    );
  }

  /// Sección de configuración de delivery.
  Widget buildDeliverySection(StoreCubit cubit, StoreCrudEditing state) {
    final edited = state.editedModel;
    return CustomListView(
      formKey: formDeliveryKey,
      title: 'Configuraciones de entregas',
      isLoading: state.isSubmitting,
      editMode: state.editMode,
      onSave: () => submit(formDeliveryKey, cubit),
      onBack: cubit.cancelEditing,
      children: [
        const Text(
          "Configura las opciones de entrega de tu comercio. Define las configuraciones de entregas para tus productos y servicios.",
        ),
        Divider(),
        SwitchListTile(
          title: const Text("Entrega en tienda"),
          subtitle: state.model.lat == null || state.model.lng == null
              ? const Text("No se ha definido la ubicación")
              : null,
          secondary: state.model.lat == null || state.model.lng == null
              ? const Icon(Icons.info)
              : null,
          value: edited.pickup,
          onChanged: (value) {
            cubit.updateEditedModel(
              (model) => model.copyWith(pickup: value),
            );
          },
        ),
        SwitchListTile(
          title: const Text("Entrega a domicilio"),
          subtitle: state.model.geom == null
              ? const Text("No se ha definido la zona de cobertura")
              : null,
          secondary: state.model.geom == null ? const Icon(Icons.info) : null,
          value: edited.delivery,
          onChanged: (value) {
            cubit.updateEditedModel(
              (model) => model.copyWith(delivery: value),
            );
          },
        ),
        TextFormField(
          initialValue: edited.deliveryMinimumOrder?.toString() ?? "",
          decoration: const InputDecoration(
            icon: Icon(Icons.monetization_on),
            labelText: "Minimo de compra",
          ),
          keyboardType: TextInputType.number,
          validator: validateNumber,
          onChanged: (value) {
            final num? minOrder = num.tryParse(value);
            cubit.updateEditedModel(
              (model) => model.copyWith(deliveryMinimumOrder: minOrder),
            );
          },
        ),
        TextFormField(
          initialValue: edited.deliveryPrice?.toString() ?? "",
          decoration: const InputDecoration(
            icon: Icon(Icons.delivery_dining),
            labelText: "Precio de entrega",
          ),
          keyboardType: TextInputType.number,
          validator: validateNumber,
          onChanged: (value) {
            final num? price = num.tryParse(value);
            cubit.updateEditedModel(
              (model) => model.copyWith(deliveryPrice: price),
            );
          },
        ),
      ],
    );
  }
}
