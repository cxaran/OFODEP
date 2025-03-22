import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/store_cubit.dart';
import 'package:ofodep/pages/error_page.dart';

class StorePage extends StatelessWidget {
  final String? storeId;

  const StorePage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return const ErrorPage();
    }
    return BlocProvider<StoreCubit>(
      create: (context) => StoreCubit(storeId!)..loadStore(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Store'),
          ),
          body: BlocConsumer<StoreCubit, StoreState>(
            listener: (context, state) {
              if (state is StoreError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is StoreEditState) {
                if (state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is StoreLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StoreLoaded) {
                return _storePage(context, state);
              } else if (state is StoreError) {
                return Center(child: Text(state.message));
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  /// Renders the store page.
  /// If in edit mode, shows forms according to the currently edited section;
  /// otherwise shows a menu of sections.
  Widget _storePage(BuildContext context, StoreLoaded state) {
    if (state is StoreEditState) {
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
    } else {
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(state.store.name),
            onTap: () => context
                .read<StoreCubit>()
                .edit(editSection: StoreEditSection.general),
          ),
          const Divider(),
          ListTile(
            title: Text(StoreEditSection.contact.description),
            subtitle: Text(
              '${state.store.addressStreet}, ${state.store.addressNumber}, '
              '${state.store.addressColony}, ${state.store.addressZipcode}\n'
              '${state.store.addressCity}, ${state.store.addressState}',
            ),
            onTap: () => context
                .read<StoreCubit>()
                .edit(editSection: StoreEditSection.contact),
          ),
          ListTile(
            title: Text(StoreEditSection.coordinates.description),
            onTap: () => context
                .read<StoreCubit>()
                .edit(editSection: StoreEditSection.coordinates),
          ),
          ListTile(
            title: Text(StoreEditSection.codePostal.description),
            onTap: () => context
                .read<StoreCubit>()
                .edit(editSection: StoreEditSection.codePostal),
          ),
          ListTile(
            title: Text(StoreEditSection.delivery.description),
            onTap: () => context
                .read<StoreCubit>()
                .edit(editSection: StoreEditSection.delivery),
          ),
          ListTile(
            title: Text(StoreEditSection.imageApi.description),
            onTap: () => context
                .read<StoreCubit>()
                .edit(editSection: StoreEditSection.imageApi),
          ),
          const Divider(),
          ListTile(
            title: const Text('Schedules'),
            onTap: () => context.push(
              '/admin/schedule/${state.store.id}',
            ),
          ),
          ListTile(
            title: const Text('Products'),
            onTap: () => context.push(
              '/admin/products/${state.store.id}',
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Orders'),
            onTap: () => context.push(
              '/admin/orders?store=${state.store.id}',
            ),
          ),
        ],
      );
    }
  }

  /// General information section: store name and logo.
  Widget _buildGeneralSection(BuildContext context, StoreEditState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Edit general information"),
        TextFormField(
          initialValue: state.name,
          decoration: const InputDecoration(labelText: "Name"),
          onChanged: (value) =>
              context.read<StoreCubit>().changed(name: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.logoUrl ?? "",
          decoration: const InputDecoration(labelText: "Logo URL"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(logoUrl: value, editMode: true),
        ),
        const SizedBox(height: 16),
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

  /// Contact and address section.
  Widget _buildContactSection(BuildContext context, StoreEditState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Edit contact and address"),
        TextFormField(
          initialValue: state.addressStreet,
          decoration: const InputDecoration(labelText: "Street"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(addressStreet: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.addressNumber,
          decoration: const InputDecoration(labelText: "Number"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(addressNumber: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.addressColony,
          decoration: const InputDecoration(labelText: "Neighborhood"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(addressColony: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.addressZipcode,
          decoration: const InputDecoration(labelText: "Zipcode"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(addressZipcode: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.addressCity,
          decoration: const InputDecoration(labelText: "City"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(addressCity: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.addressState,
          decoration: const InputDecoration(labelText: "State"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(addressState: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.whatsapp,
          decoration: const InputDecoration(labelText: "WhatsApp"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(whatsapp: value, editMode: true),
        ),
        const SizedBox(height: 16),
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

  /// Geographical coordinates section.
  Widget _buildCoordinatesSection(BuildContext context, StoreEditState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Edit location"),
        TextFormField(
          initialValue: state.lat?.toString() ?? "",
          decoration: const InputDecoration(labelText: "Latitude"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? lat = num.tryParse(value);
            context.read<StoreCubit>().changed(lat: lat, editMode: true);
          },
        ),
        TextFormField(
          initialValue: state.lng?.toString() ?? "",
          decoration: const InputDecoration(labelText: "Longitude"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? lng = num.tryParse(value);
            context.read<StoreCubit>().changed(lng: lng, editMode: true);
          },
        ),
        const SizedBox(height: 16),
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

  /// Coverage areas section (zipcodes).
  Widget _buildCodePostalSection(BuildContext context, StoreEditState state) {
    final initialValue = state.zipcodes?.join(', ') ?? "";
    return ListView(
      padding: const EdgeInsets.all(16),
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
            context.read<StoreCubit>().changed(zipcodes: codes, editMode: true);
          },
        ),
        const SizedBox(height: 16),
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

  /// Delivery configuration section.
  Widget _buildDeliverySection(BuildContext context, StoreEditState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Edit delivery settings"),
        TextFormField(
          initialValue: state.deliveryMinimumOrder?.toString() ?? "",
          decoration: const InputDecoration(
            labelText: "Minimum order for delivery",
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? minOrder = num.tryParse(value);
            context
                .read<StoreCubit>()
                .changed(deliveryMinimumOrder: minOrder, editMode: true);
          },
        ),
        SwitchListTile(
          title: const Text("Pickup"),
          value: state.pickup,
          onChanged: (value) =>
              context.read<StoreCubit>().changed(pickup: value, editMode: true),
        ),
        SwitchListTile(
          title: const Text("Delivery"),
          value: state.delivery,
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(delivery: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.deliveryPrice?.toString() ?? "",
          decoration: const InputDecoration(labelText: "Delivery price"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num? price = num.tryParse(value);
            context
                .read<StoreCubit>()
                .changed(deliveryPrice: price, editMode: true);
          },
        ),
        const SizedBox(height: 16),
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

  /// Image configuration section (Imgur).
  Widget _buildImageApiSection(BuildContext context, StoreEditState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Edit image configuration (Imgur)"),
        TextFormField(
          initialValue: state.imgurClientId ?? "",
          decoration: const InputDecoration(labelText: "Imgur Client ID"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(imgurClientId: value, editMode: true),
        ),
        TextFormField(
          initialValue: state.imgurClientSecret ?? "",
          decoration: const InputDecoration(labelText: "Imgur Client Secret"),
          onChanged: (value) => context
              .read<StoreCubit>()
              .changed(imgurClientSecret: value, editMode: true),
        ),
        const SizedBox(height: 16),
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
}
