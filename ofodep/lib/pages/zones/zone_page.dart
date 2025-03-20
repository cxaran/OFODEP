import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/zone_cubit.dart';
import 'package:ofodep/pages/error_page.dart';
import 'package:ofodep/widgets/zone_polygon.dart';

class ZonePage extends StatelessWidget {
  final String? zoneId;
  const ZonePage({super.key, this.zoneId});

  @override
  Widget build(BuildContext context) {
    if (zoneId == null) {
      return ErrorPage();
    }

    return BlocProvider<ZoneCubit>(
      create: (context) => ZoneCubit(zoneId!)..loadZone(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Editar Zona'),
          ),
          body: BlocConsumer<ZoneCubit, ZoneState>(
            listener: (context, state) {
              if (state is ZoneError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is ZoneEditState) {
                if (state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is ZoneLoading || state is ZoneInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ZoneError) {
                return Center(child: Text(state.message));
              } else if (state is ZoneEditState) {
                return Column(
                  children: [
                    TextField(
                      key: const ValueKey('name_zone'),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: state.nombre,
                          selection: TextSelection.collapsed(
                              offset: state.nombre.length),
                        ),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la zona',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          context.read<ZoneCubit>().nameChanged(value),
                    ),
                    TextField(
                      key: const ValueKey('description_zone'),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: state.descripcion,
                          selection: TextSelection.collapsed(
                              offset: state.descripcion.length),
                        ),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          context.read<ZoneCubit>().descriptionChanged(value),
                    ),
                    Expanded(
                      child: ZonePolygon(geom: state.geom),
                    ),
                    state.isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => context.read<ZoneCubit>().submit(),
                            child: const Text('Guardar'),
                          ),
                  ],
                );
              }
              return Container();
            },
          ),
        );
      }),
    );
  }
}
