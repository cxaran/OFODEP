import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/local_cubits/zipcodes_cubit.dart';
import 'package:ofodep/repositories/location_repository.dart';

class ZipcodesSelector extends StatelessWidget {
  final List<String> zipcodes;
  final void Function(String, List<String>) onZipcodeUpdated;
  final String? countryCode;

  ZipcodesSelector({
    super.key,
    this.zipcodes = const [],
    required this.onZipcodeUpdated,
    this.countryCode,
  });

  final TextEditingController controller = TextEditingController();

  final countries = <Map<String, String>>[
    {'code': 'AR', 'name': 'Argentina'},
    {'code': 'BO', 'name': 'Bolivia'},
    {'code': 'BR', 'name': 'Brazil'},
    {'code': 'CL', 'name': 'Chile'},
    {'code': 'CO', 'name': 'Colombia'},
    {'code': 'CR', 'name': 'Costa Rica'},
    {'code': 'CU', 'name': 'Cuba'},
    {'code': 'DO', 'name': 'Dominican Republic'},
    {'code': 'EC', 'name': 'Ecuador'},
    {'code': 'SV', 'name': 'El Salvador'},
    {'code': 'GT', 'name': 'Guatemala'},
    {'code': 'HN', 'name': 'Honduras'},
    {'code': 'MX', 'name': 'Mexico'},
    {'code': 'NI', 'name': 'Nicaragua'},
    {'code': 'PA', 'name': 'Panama'},
    {'code': 'PY', 'name': 'Paraguay'},
    {'code': 'PE', 'name': 'Peru'},
    {'code': 'UY', 'name': 'Uruguay'},
    {'code': 'VE', 'name': 'Venezuela'},
    {'code': 'HT', 'name': 'Haiti'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'US', 'name': 'United States'},
  ];

  void onAdd(String zipcode) {
    if (!zipcodes.contains(zipcode)) {
      onZipcodeUpdated(
        countryCode!,
        [...zipcodes, zipcode],
      );
    }
  }

  void onDelete(String zipcode) {
    onZipcodeUpdated(
      countryCode!,
      [...zipcodes.where((e) => e != zipcode)],
    );
  }

  void onChangedCountryCode(String? code) {
    if (code != null) {
      onZipcodeUpdated(code, []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZipcodesCubit>(
      create: (context) => ZipcodesCubit(),
      child: Builder(builder: (context) {
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: countryCode,
              items: countries.map((country) {
                return DropdownMenuItem(
                  value: country['code'],
                  child: Text(country['name']!),
                );
              }).toList(),
              onChanged: onChangedCountryCode,
              decoration: const InputDecoration(
                labelText: 'country',
              ),
            ),
            if (countryCode != null) ...[
              Wrap(
                children: zipcodes
                    .map(
                      (zipcode) => Chip(
                        label: FutureBuilder(
                            future: LocationRepository().getLocationFromZipCode(
                                countryCode: countryCode!, zipCode: zipcode),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final location = snapshot.data!;
                                return Text(
                                  '$zipcode ${location.city},'
                                  ' ${location.state},'
                                  ' ${location.country}',
                                );
                              }

                              return Text(zipcode);
                            }),
                        onDeleted: () => onDelete(zipcode),
                      ),
                    )
                    .toList(),
              ),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'address',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () =>
                        context.read<ZipcodesCubit>().searchZipcodes(
                              countryCode: countryCode!,
                              query: controller.text,
                            ),
                  ),
                ),
              ),
              BlocBuilder<ZipcodesCubit, ZipcodesState>(
                builder: (context, state) {
                  if (state.searchResults.isEmpty) {
                    return Container();
                  }
                  return Column(
                    children: state.searchResults
                        .map(
                          (location) => ListTile(
                            title: Text(location.zipCode),
                            subtitle: Builder(builder: (context) {
                              debugPrint(location.toString());
                              return Text(
                                '${location.city},\n'
                                '${location.state}, ${location.country}',
                              );
                            }),
                            onTap: () => onAdd(location.zipCode),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ],
        );
      }),
    );
  }
}
