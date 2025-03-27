import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/local_cubits/zipcodes_cubit.dart';

class ZipcodesSelector extends StatelessWidget {
  final List<String> zipcodes;
  final void Function(List<String>) onZipcodeUpdated;

  ZipcodesSelector({
    super.key,
    this.zipcodes = const [],
    required this.onZipcodeUpdated,
  });

  final TextEditingController controller = TextEditingController();

  void onAdd(String zipcode) {
    if (!zipcodes.contains(zipcode)) {
      onZipcodeUpdated([...zipcodes, zipcode]);
    }
  }

  void onDelete(String zipcode) {
    onZipcodeUpdated([...zipcodes.where((e) => e != zipcode)]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZipcodesCubit>(
      create: (context) => ZipcodesCubit(),
      child: Column(
        children: [
          Wrap(
            children: zipcodes
                .map(
                  (zipcode) => Chip(
                    label: Text(zipcode),
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
                onPressed: () => context
                    .read<ZipcodesCubit>()
                    .searchZipcodes(controller.text),
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
                        subtitle: Text(location.city ?? ''),
                        onTap: () => onAdd(location.zipCode),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
