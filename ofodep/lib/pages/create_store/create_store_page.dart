import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/create_store_cubit.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/const.dart';
import 'package:ofodep/models/country_timezone.dart';
import 'package:ofodep/models/create_store_model.dart';
import 'package:ofodep/pages/create_store/terms_create_store.dart';
import 'package:ofodep/widgets/container_page.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: ContainerPage(
                child: SizedBox(
                  height: height > 300 ? 300 : height,
                  child: CarouselView.weighted(
                    controller: controller,
                    itemSnapping: true,
                    flexWeights: const <int>[1, 7, 1],
                    children: images
                        .map(
                          (InfoImage image) => HeroLayoutCard(
                            imageInfo: image,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: ContainerPage(
          child: BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) {
            if (state is SessionUnauthenticated) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Debes iniciar sesión'),
                ),
              );
            }
            if (state is SessionAuthenticated) {
              if (state.storeId != null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Gracias por registrar tu comercio, te contactaremos lo antes posible.',
                    ),
                  ),
                );
              }
            }

            return CrudStateHandler<CreateStoreModel>(
              createCubit: (context) => CreateStoreCubit(
                initialState: CrudEditing<CreateStoreModel>.fromModel(
                  CreateStoreModel.empty(),
                ),
              ),
              loadedBuilder: (context, model) => SizedBox.shrink(),
              editingBuilder: (
                cubit,
                model,
                editedModel,
                editMode,
                isSubmitting,
                errorMessage,
              ) =>
                  Form(
                key: _formKey,
                child: ListView(
                  children: [
                    gap,
                    gap,
                    Text(
                      'Solicita tu prueba gratuita',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    gap,
                    TextFormField(
                      initialValue: editedModel.storeName,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo del comercio',
                        hintText: 'Comercio',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduzca un nombre completo';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        cubit.updateEditingState(
                          (model) => model.copyWith(
                            storeName: value,
                          ),
                        );
                      },
                    ),
                    gap,
                    DropdownButtonFormField<CountryTimezone>(
                      decoration: InputDecoration(
                        labelText: 'Zona del comercio',
                      ),
                      value: editedModel.countryCode == '' ||
                              editedModel.timezone == ''
                          ? null
                          : CountryTimezone(
                              country: editedModel.countryCode,
                              timezone: editedModel.timezone,
                            ),
                      items: timeZonesLatAm
                          .map((tz) => DropdownMenuItem<CountryTimezone>(
                                value: tz,
                                child: Text('${tz.timezone} (${tz.country})'),
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
                    gap,
                    Text(
                      'Los datos de contacto serán utilizados para que un representante se comunique contigo y coordine los detalles del proceso de evaluación y acuerdo comercial.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    gap,
                    TextFormField(
                      initialValue: editedModel.contactName,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del contacto',
                        hintText: 'Jhon Doe',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduzca un nombre';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        cubit.updateEditingState(
                          (model) => model.copyWith(contactName: value),
                        );
                      },
                    ),
                    gap,
                    TextFormField(
                      initialValue: editedModel.contactEmail,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico del contacto',
                        hintText: 'correo@example.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduzca un correo electrónico';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        cubit.updateEditingState(
                          (model) => model.copyWith(contactEmail: value),
                        );
                      },
                    ),
                    gap,
                    TextFormField(
                      initialValue: editedModel.contactPhone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono del contacto',
                        hintText: '+52 123456789',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduzca un teléfono';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        cubit.updateEditingState(
                          (model) => model.copyWith(contactPhone: value),
                        );
                      },
                    ),
                    gap,
                    FormField<bool>(
                      initialValue: false,
                      validator: (value) {
                        if (value != true) {
                          return 'Debes aceptar los Términos y Condiciones';
                        }
                        return null;
                      },
                      builder: (state) => Row(
                        children: [
                          Checkbox(
                            value: state.value,
                            onChanged: (value) => state.didChange(value),
                            isError: state.hasError,
                          ),
                          InkWell(
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => TermsCreateStore(),
                            ),
                            child: const Text(
                              'Acepto los Términos y Condiciones',
                            ),
                          ),
                        ],
                      ),
                    ),
                    gap,
                    ElevatedButton(
                      onPressed: !editMode || isSubmitting
                          ? null
                          : () async {
                              final session = context.read<SessionCubit>();
                              if (_formKey.currentState?.validate() ?? false) {
                                final newId = await cubit.create();
                                if (newId != null) {
                                  session.addStore(newId);
                                }
                              }
                            }, // verificar el from primero
                      child: isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text("Guardar"),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
