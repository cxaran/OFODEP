import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/create_store_cubit.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/models/country_timezone.dart';
import 'package:ofodep/models/create_store_model.dart';
import 'package:ofodep/pages/create_store/terms_create_store.dart';
import 'package:ofodep/repositories/store_admin_repository.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/container_page.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/hero_layout_card.dart';
import 'package:ofodep/widgets/message_page.dart';

const List<InfoImage> images = [
  InfoImage(
    'Solicita tu Periodo\nde Prueba Gratis',
    'Llena el formulario, revisaremos tu solicitud y te contactaremos para ajustar detalles. Comienza con un periodo de prueba sin compromiso.',
    'https://i.imgur.com/rA0RnMd.png',
  ),
  InfoImage(
    'Tu comercio Online \nen Minutos',
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
    UserModel? user = context.read<SessionCubit>().user;

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
        body: user == null
            ? MessagePage.warning('Inicia sesión para registrar tu comercio.')
            : FutureBuilder(
                future: StoreAdminRepository().getById(
                  user.id,
                  field: 'user_id',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return MessagePage.warning(
                        'Tu comercio "${snapshot.data?.storeName}" ya ha sido registrado.',
                      );
                    }
                  }
                  return CrudStateHandler<CreateStoreModel, CreateStoreCubit>(
                    createCubit: (context) => CreateStoreCubit()
                      ..load(
                        null,
                        createModel: CreateStoreModel.empty(),
                      ),
                    loadedBuilder: (_, __, ___) => SizedBox.shrink(),
                    editingBuilder: (_, __, ___) => SizedBox.shrink(),
                    creatingBuilder: (
                      context,
                      CreateStoreCubit cubit,
                      CrudCreate<CreateStoreModel> state,
                    ) =>
                        CustomListView(
                      formKey: _formKey,
                      isLoading: state.isSubmitting,
                      onSave: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final newId = await cubit.create();
                          if (newId != null && context.mounted) {
                            context.pushReplacement(
                              '/admin/store/$newId',
                            );
                          }
                        }
                      },
                      children: [
                        Text(
                          'Solicita tu prueba gratuita',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextFormField(
                          initialValue: state.editedModel.storeName,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.storefront),
                            labelText: 'Nombre completo del comercio',
                            hintText: 'Comercio',
                          ),
                          validator: validate,
                          onChanged: (value) {
                            cubit.updateEditedModel(
                              (model) => model.copyWith(
                                storeName: value,
                              ),
                            );
                          },
                        ),
                        DropdownButtonFormField<CountryTimezone>(
                          decoration: InputDecoration(
                            icon: const Icon(Icons.map),
                            labelText: 'Zona del comercio',
                          ),
                          value: state.editedModel.countryCode == '' ||
                                  state.editedModel.timezone == ''
                              ? null
                              : CountryTimezone(
                                  country: state.editedModel.countryCode,
                                  timezone: state.editedModel.timezone,
                                ),
                          items: timeZonesLatAm
                              .map(
                                (tz) => DropdownMenuItem<CountryTimezone>(
                                  value: tz,
                                  child: Text(
                                      '${tz.timezone.replaceAll('America/', '')} (${tz.country})'),
                                ),
                              )
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
                        Divider(),
                        Text(
                          'Los datos de contacto serán utilizados para que un representante se comunique contigo y coordine los detalles del proceso de evaluación y acuerdo comercial.',
                        ),
                        TextFormField(
                          initialValue: state.editedModel.contactName,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            labelText: 'Nombre del contacto',
                            hintText: 'Jhon Doe',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduzca un nombre';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            cubit.updateEditedModel(
                              (model) => model.copyWith(contactName: value),
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: state.editedModel.contactEmail,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.email),
                            labelText: 'Correo electrónico del contacto',
                            hintText: 'correo@example.com',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduzca un correo electrónico';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            cubit.updateEditedModel(
                              (model) => model.copyWith(contactEmail: value),
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: state.editedModel.contactPhone,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.phone),
                            labelText: 'Teléfono del contacto',
                            hintText: '+52 123456789',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduzca un teléfono';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            cubit.updateEditedModel(
                              (model) => model.copyWith(contactPhone: value),
                            );
                          },
                        ),
                        Divider(),
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
                      ],
                    ),
                  );
                }),
      ),
    );
  }
}
