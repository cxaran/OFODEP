import 'package:flutter/material.dart';

import 'package:ofodep/widgets/location_button.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  // Explorar
  // Delivery
  // Pickup
  // Promociones
  // Tendencias
  // Reciente
  // Comentadas

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            floating: true,
            snap: true,
            title: const Text('Explorar'),
            forceElevated: innerBoxIsScrolled,
            actions: [LocationButton()],
          ),
        ];
      },
      body: Container(),
    );
  }
}
