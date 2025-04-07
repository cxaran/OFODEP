import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/create_store_cubit.dart';
import 'package:ofodep/const.dart';
import 'package:ofodep/models/create_store_model.dart';
import 'package:ofodep/widgets/hero_layout_card.dart';

const List<InfoImage> images = [
  InfoImage(
    'Solicita tu Periodo\nde Prueba Gratis',
    'Llena el formulario, revisaremos tu solicitud y te contactaremos para ajustar detalles. Comienza con un periodo de prueba sin compromiso.',
    'https://i.imgur.com/rA0RnMd.png',
  ),
  InfoImage(
    'Tu Tienda Online \nen Minutos',
    'Publica tus productos y comienza a recibir pedidos sin necesidad de conocimientos técnicos. Solo regístrate y solicita tu activación.',
    'https://i.imgur.com/5JmScxN.png',
  ),
  InfoImage(
    'Pedidos Simples \ny Personalizados',
    'Tus clientes podrán elegir, personalizar y ordenar fácilmente desde su celular, con entrega o recogida.',
    'https://i.imgur.com/DfKaIt9.png',
  ),
  InfoImage(
    'Atención Directa \npor WhatsApp',
    'Recibe y gestiona pedidos directamente por WhatsApp si lo prefieres. Comunicación directa y sin complicaciones.',
    'https://i.imgur.com/3dcGJB1.png',
  ),
  InfoImage(
    'Gestión Clara de \nEntregas y Horarios',
    'Controla tus horarios de apertura y gestiona entregas y su reparticion de manera eficiente.',
    'https://i.imgur.com/nqW4JkR.png',
  ),
  InfoImage(
    'Crece con Reseñas \ny Visibilidad Local',
    'Tus clientes te califican y ayudan a que más personas confíen en ti. Gana reputación con cada entrega.',
    'https://i.imgur.com/3dcGJB1.png',
  ),
];

class CreateStorePage extends StatefulWidget {
  const CreateStorePage({super.key});

  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CarouselView _carouselView = CarouselView.weighted(
      controller: controller,
      itemSnapping: true,
      flexWeights: const <int>[1, 7, 1],
      children: images.map((InfoImage image) {
        return HeroLayoutCard(imageInfo: image);
      }).toList(),
    );

    double height = MediaQuery.sizeOf(context).height / 2;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text('Registra tu comercio'),
              forceElevated: innerBoxIsScrolled,
              forceMaterialTransparency: true,
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: height > 300 ? 300 : height,
                child: CarouselView.weighted(
                  controller: controller,
                  itemSnapping: true,
                  flexWeights: const <int>[1, 7, 1],
                  children: images.map(
                    (InfoImage image) {
                      return HeroLayoutCard(imageInfo: image);
                    },
                  ).toList(),
                ),
              ),
            ),
          ];
        },
        body: BlocProvider<CreateStoreCubit>(
          create: (context) => CreateStoreCubit(
            initialState: CrudEditing<CreateStoreModel>.fromModel(
              CreateStoreModel(
                id: '',
                storeName: '',
                countryCode: '',
                timezone: '',
                contactName: '',
                contactEmail: '',
                contactPhone: '',
              ),
            ),
          ),
          child: Builder(
            builder: (context) =>
                BlocConsumer<CreateStoreCubit, CrudState<CreateStoreModel>>(
              listener: (context, state) {
                if (state is CrudError<CreateStoreModel>) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is CrudEditing<CreateStoreModel> &&
                    state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
              },
              builder: (context, state) {
                if (state is CrudLoading<CreateStoreModel>) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CrudLoaded<CreateStoreModel> ||
                    state is CrudEditing<CreateStoreModel>) {
                  return _createStorePage(context, state);
                } else if (state is CrudError<CreateStoreModel>) {
                  return Center(child: Text(state.message));
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Renderiza la página de la tienda.
  /// Muestra el formulario de edición,
  Widget _createStorePage(
      BuildContext context, CrudState<CreateStoreModel> state) {
    if (state is CrudEditing<CreateStoreModel>) {
      return Form(
        child: ListView(
          children: [
            TextFormField(
              initialValue: state.editedModel.storeName,
              decoration: const InputDecoration(
                labelText: 'Nombre completo del comercio',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduzca un nombre completo';
                }
                return null;
              },
              onChanged: (value) {
                context.read<CreateStoreCubit>().updateEditingState(
                      (model) => model.copyWith(storeName: value),
                    );
              },
            ),
            DropdownButton<Map<String, String>>(
              value: state.editedModel.countryCode == '' ||
                      state.editedModel.timezone == ''
                  ? null
                  : {
                      'country': state.editedModel.countryCode,
                      'timezone': state.editedModel.timezone,
                    },
              items: timeZonesLatAm
                  .map((tz) => DropdownMenuItem<Map<String, String>>(
                        value: tz,
                        child: Text('${tz['country']} (${tz['timezone']})'),
                      ))
                  .toList(),
              onChanged: (tz) {
                context.read<CreateStoreCubit>().updateEditingState(
                      (model) => model.copyWith(
                        countryCode: tz?['country'],
                        timezone: tz?['timezone'],
                      ),
                    );
              },
            ),
            TextFormField(
              initialValue: state.editedModel.contactName,
              decoration: const InputDecoration(
                labelText: 'Nombre del contacto',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduzca un nombre';
                }
                return null;
              },
              onChanged: (value) {
                context.read<CreateStoreCubit>().updateEditingState(
                      (model) => model.copyWith(contactName: value),
                    );
              },
            ),
            TextFormField(
              initialValue: state.editedModel.contactEmail,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico del contacto',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduzca un correo electrónico';
                }
                return null;
              },
              onChanged: (value) {
                context.read<CreateStoreCubit>().updateEditingState(
                      (model) => model.copyWith(contactEmail: value),
                    );
              },
            ),
            TextFormField(
              initialValue: state.editedModel.contactPhone,
              decoration: const InputDecoration(
                labelText: 'Teléfono del contacto',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduzca un teléfono';
                }
                return null;
              },
              onChanged: (value) {
                context.read<CreateStoreCubit>().updateEditingState(
                      (model) => model.copyWith(contactPhone: value),
                    );
              },
            ),
            ElevatedButton(
              onPressed: state.isSubmitting || !state.editMode
                  ? null
                  : () => context.read<CreateStoreCubit>().submit(),
              child: state.isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text("Guardar"),
            ),
            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => context.read<CreateStoreCubit>().cancelEditing(),
              child: state.isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text("Cancelar"),
            ),
          ],
        ),
      );
    }
    return Container();
  }
}
