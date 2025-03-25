import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_cubit.dart';
import 'package:ofodep/pages/error_page.dart';
import 'package:ofodep/models/store_model.dart';

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
        case StoreEditSection.codePostal:
          return _buildCodePostalSection(context, state);
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
            title: Text(StoreEditSection.codePostal.description),
            onTap: () => context
                .read<StoreCubit>()
                .startEditing(editSection: StoreEditSection.codePostal),
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
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(labelText: "Name"),
          onChanged: (value) {
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(name: value));
          },
        ),
        TextFormField(
          initialValue: edited.logoUrl ?? "",
          decoration: const InputDecoration(labelText: "Logo URL"),
          onChanged: (value) {
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(logoUrl: value));
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
    return ListView(
      children: [
        const Text("Edit location"),
        TextFormField(
          initialValue: edited.lat?.toString() ?? "",
          decoration: const InputDecoration(labelText: "Latitude"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? lat = num.tryParse(value);
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(lat: lat));
          },
        ),
        TextFormField(
          initialValue: edited.lng?.toString() ?? "",
          decoration: const InputDecoration(labelText: "Longitude"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? lng = num.tryParse(value);
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(lng: lng));
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

  /// Sección de áreas de cobertura (zipcodes).
  Widget _buildCodePostalSection(BuildContext context, StoreCrudEditing state) {
    final edited = state.editedModel;
    final initialValue = edited.zipcodes?.join(', ') ?? "";
    return ListView(
      children: [
        const Text("Edit coverage areas"),
        TextFormField(
          initialValue: initialValue,
          decoration: const InputDecoration(
            labelText: "Zipcodes (comma-separated)",
          ),
          onChanged: (value) {
            final codes = value
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            context
                .read<StoreCubit>()
                .updateEditingState((model) => model.copyWith(zipcodes: codes));
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
