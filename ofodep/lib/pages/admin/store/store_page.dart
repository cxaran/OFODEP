import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_cubit.dart';
import 'package:ofodep/pages/error_page.dart';
import 'package:ofodep/models/store_model.dart';
import 'package:ofodep/widgets/admin_image.dart';
import 'package:ofodep/widgets/location_picker.dart';
import 'package:ofodep/widgets/zone_polygon.dart';

class StorePage extends StatelessWidget {
  final String? storeId;

  const StorePage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return const ErrorPage();
    }
    return BlocProvider<StoreCubit>(
      create: (context) => StoreCubit(id: storeId!)..load(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Store'),
          ),
          body: BlocConsumer<StoreCubit, CrudState<StoreModel>>(
            listener: (context, state) {
              if (state is CrudError<StoreModel>) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is StoreCrudEditing &&
                  state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
            builder: (context, state) {
              if (state is CrudLoading<StoreModel>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CrudLoaded<StoreModel> ||
                  state is StoreCrudEditing) {
                return _storePage(context, state);
              } else if (state is CrudError<StoreModel>) {
                return Center(child: Text(state.message));
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  /// Renderiza la página de la tienda.
  /// Si el estado es de edición (StoreCrudEditing) muestra el formulario según la sección,
  /// de lo contrario muestra un menú de secciones.
  Widget _storePage(BuildContext context, CrudState<StoreModel> state) {
    if (state is StoreCrudEditing) {
      switch (state.editSection) {
        case StoreEditSection.general:
          return _buildGeneralSection(context, state);
        case StoreEditSection.contact:
          return _buildContactSection(context, state);
        case StoreEditSection.coordinates:
          return _buildCoordinatesSection(context, state);
        case StoreEditSection.geom:
          return _buildGeomSection(context, state);
        case StoreEditSection.delivery:
          return _buildDeliverySection(context, state);
        case StoreEditSection.imageApi:
          return _buildImageApiSection(context, state);
      }
    } else if (state is CrudLoaded<StoreModel>) {
      final store = state.model;
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(store.name),
            onTap: () => context
                .read<StoreCubit>()
                .startEditing(editSection: StoreEditSection.general),
          ),
          const Divider(),
          ListTile(
            title: Text(StoreEditSection.contact.description),
            subtitle: Text(
              '${store.addressStreet}, ${store.addressNumber}, '
              '${store.addressColony}, ${store.addressZipcode}\n'
              '${store.addressCity}, ${store.addressState}',
            ),
            onTap: () => context
                .read<StoreCubit>()
                .startEditing(editSection: StoreEditSection.contact),
          ),
          ListTile(
            title: Text(StoreEditSection.coordinates.description),
            onTap: () => context
                .read<StoreCubit>()
                .startEditing(editSection: StoreEditSection.coordinates),
          ),
          ListTile(
            title: Text(StoreEditSection.geom.description),
            onTap: () => context
                .read<StoreCubit>()
                .startEditing(editSection: StoreEditSection.geom),
          ),
          ListTile(
            title: Text(StoreEditSection.delivery.description),
            onTap: () => context
                .read<StoreCubit>()
                .startEditing(editSection: StoreEditSection.delivery),
          ),
          ListTile(
            title: Text(StoreEditSection.imageApi.description),
            onTap: () => context
                .read<StoreCubit>()
                .startEditing(editSection: StoreEditSection.imageApi),
          ),
          const Divider(),
          ListTile(
            title: const Text('Schedules'),
            onTap: () => context.push('/admin/schedules/${store.id}'),
          ),
          ListTile(
            title: const Text('Schedule Exceptions'),
            onTap: () => context.push('/admin/schedule_exceptions/${store.id}'),
          ),
          ListTile(
            title: const Text('Products'),
            onTap: () => context.push('/admin/products/${store.id}'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Orders'),
            onTap: () => context.push('/admin/orders?store=${store.id}'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Subscription'),
            onTap: () => context.push('/admin/subscription/${store.id}'),
          ),
          ListTile(
            title: const Text('Store Admins'),
            onTap: () => context.push('/admin/store_admins/${store.id}'),
          ),
        ],
      );
    }
    return Container();
  }

  /// Sección general: nombre y logo de la tienda.
  Widget _buildGeneralSection(BuildContext context, StoreCrudEditing state) {
    final edited = state.editedModel;
    return ListView(
      children: [
        const Text("Edit general information"),
        AdminImage(
          clientId: edited.imgurClientId,
          imageUrl: edited.logoUrl,
          onImageUploaded: (url) {
            context.read<StoreCubit>().updateEditingState(
                  (model) => model.copyWith(logoUrl: url),
                );
          },
        ),
        if (edited.imgurClientId == null) Text('imgur_client_is_null'),
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(labelText: "Name"),
          onChanged: (value) => context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(
                  name: value,
                ),
              ),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => context.read<StoreCubit>().submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () => context.read<StoreCubit>().cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }

  /// Sección de contacto y dirección.
  Widget _buildContactSection(BuildContext context, StoreCrudEditing state) {
    final edited = state.editedModel;
    return ListView(
      children: [
        const Text("Edit contact and address"),
        TextFormField(
          initialValue: edited.addressStreet,
          decoration: const InputDecoration(labelText: "Street"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(addressStreet: value));
          },
        ),
        TextFormField(
          initialValue: edited.addressNumber,
          decoration: const InputDecoration(labelText: "Number"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(addressNumber: value));
          },
        ),
        TextFormField(
          initialValue: edited.addressColony,
          decoration: const InputDecoration(labelText: "Neighborhood"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(addressColony: value));
          },
        ),
        TextFormField(
          initialValue: edited.addressZipcode,
          decoration: const InputDecoration(labelText: "Zipcode"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(addressZipcode: value));
          },
        ),
        TextFormField(
          initialValue: edited.addressCity,
          decoration: const InputDecoration(labelText: "City"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(addressCity: value));
          },
        ),
        TextFormField(
          initialValue: edited.addressState,
          decoration: const InputDecoration(labelText: "State"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(addressState: value));
          },
        ),
        TextFormField(
          initialValue: edited.countryCode,
          decoration: const InputDecoration(labelText: "Country code, e.g. MX"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(countryCode: value));
          },
        ),
        TextFormField(
          initialValue: edited.whatsapp,
          decoration: const InputDecoration(labelText: "WhatsApp"),
          onChanged: (value) {
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(whatsapp: value));
          },
        ),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => context.read<StoreCubit>().submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () => context.read<StoreCubit>().cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }

  /// Sección de coordenadas geográficas.
  Widget _buildCoordinatesSection(
      BuildContext context, StoreCrudEditing state) {
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
            onLocationChanged: (p0) =>
                context.read<StoreCubit>().updateEditingState(
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
              : () => context.read<StoreCubit>().submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () => context.read<StoreCubit>().cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }

  /// Sección de áreas de cobertura (zipcodes).
  Widget _buildGeomSection(BuildContext context, StoreCrudEditing state) {
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
              context.read<StoreCubit>().updateEditingState(
                    (model) => model.copyWith(geom: geom),
                  );
            },
          ),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => context.read<StoreCubit>().submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () => context.read<StoreCubit>().cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }

  /// Sección de configuración de delivery.
  Widget _buildDeliverySection(BuildContext context, StoreCrudEditing state) {
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
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(deliveryMinimumOrder: minOrder));
          },
        ),
        SwitchListTile(
          title: const Text("Pickup"),
          value: edited.pickup,
          onChanged: (value) {
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(pickup: value));
          },
        ),
        SwitchListTile(
          title: const Text("Delivery"),
          value: edited.delivery,
          onChanged: (value) {
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(delivery: value));
          },
        ),
        TextFormField(
          initialValue: edited.deliveryPrice?.toString() ?? "",
          decoration: const InputDecoration(labelText: "Delivery price"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? price = num.tryParse(value);
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(deliveryPrice: price));
          },
        ),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => context.read<StoreCubit>().submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () => context.read<StoreCubit>().cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }

  /// Sección de configuración de imágenes (Imgur).
  Widget _buildImageApiSection(BuildContext context, StoreCrudEditing state) {
    final edited = state.editedModel;
    return ListView(
      children: [
        const Text("Edit image configuration (Imgur)"),
        Text('https://api.imgur.com/oauth2/addclient'),
        TextFormField(
          initialValue: edited.imgurClientId ?? "",
          decoration: const InputDecoration(labelText: "Imgur Client ID"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(imgurClientId: value));
          },
        ),
        TextFormField(
          initialValue: edited.imgurClientSecret ?? "",
          decoration: const InputDecoration(labelText: "Imgur Client Secret"),
          onChanged: (value) {
            context.read<StoreCubit>().updateEditingState(
                (model) => model.copyWith(imgurClientSecret: value));
          },
        ),
        ElevatedButton(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => context.read<StoreCubit>().submit(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
        ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () => context.read<StoreCubit>().cancelEditing(),
          child: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancel"),
        ),
      ],
    );
  }
}
