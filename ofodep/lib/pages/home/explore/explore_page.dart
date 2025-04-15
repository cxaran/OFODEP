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

  // Filtro forzoso: posicion lat y lng y distancia

  // Campos de busqueda o like: nombre del producto,  nombre de la store, categoria, tags

  // Filtro exacto: tags

  // Filtros boleanos: delivery, pickup, ofertas, envios gratis,

  // Ordenamiento: precio, recientes

  // Filtros lte: precio, minimo de compra para entrega

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
