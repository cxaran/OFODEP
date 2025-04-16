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

  /// ayudame a crear una funcion rpc para explorar que los usuarios exploren los productos de stores cercanos llamada product_explore

  /// Filtro forzoso:
  ///   country_code para un primero filtro
  ///   posicion lat y lng y distancia maxima
  ///   se obtiene la lista de productos segun la ubicacion de la store los que estan dentro de la distancia del usuario
  ///   con un maximo de 10 kilometros
  /// Paginacion:
  ///   numero de pagina y numero de productos por pagina
  /// Ordenamiento random por default:
  ///   md5(id || '$randomSeed') se manda el randomSeed como parametro
  ///   se obtiene una lista de productos aleatorios ordenados segun la semilla dada
  /// Ordenamiento se aplica despues del random opcional:
  ///   precio, recientes
  /// Campos de busqueda o like opcional:
  ///   texto de búsqueda como parametro
  ///   nombre del producto,  nombre de la store, categoria, tags
  /// Filtro exacto:
  ///   se manda como parametro un lista de valores de tags
  ///   se obtiene un listado de productos que tengan al menos uno de los tags dados
  /// Filtros boleanos:
  ///   delivery : lat y lng dados estan dentro del geom de la store (dentro de la zona de entrega a domicilio) && la store delivery es true
  ///   pickup: la store tiene pickup true
  ///   ofertas: donde el precio regular es diferente del precio del producto dado por la funcion (product_price != regular_price)
  ///   envios gratis: store delivery es true y delivery_price es 0
  /// Filtros lte gte:
  ///   product_price dado por la funcion esta en un rango de dado
  ///
  /// Consideraciones:
  /// Se consideran primero los productos de las stores que tienen el country_code dado por parametro
  /// Se caclula la distancia de la store a la ubicacion del usuario
  /// Se retornan solo las stores que tienen una distancia menor o igual a la distancia maxima
  /// Solo retorna prodcutos activos
  /// Se aplican los filtros opciones mas especificos segun el mejor orden para optmizar el rendimiento
  /// Verificar si el producto esta disponible en el dia la semana actual segun el campo days de productos, y retornar en un campo boleano available_day toma en cuenta el timezone de la store
  /// agregar el campo public.store_is_open
  /// ordenar de forma fija siempre sin importar los filtros ordenamiento en available_day(tru-false) y despues store_is_open(true-false) para un resultado:
  ///   1 store_is_open: true
  ///       2 available_day: true
  ///       3 available_day: false
  ///   4 store_is_open: false
  ///       5 available_day: true
  ///       6 available_day: false
  /// Retornar:
  /// informacion del producto:
  ///   id, name, description, image_url, regular_price, sale_price, sale_start, sale_end, currency, tags, days,
  /// informacion de la store:
  ///   id, name, logo_url, lat, lng, pickup, delivery, delivery_price,
  /// informacion calculada:
  ///   store_is_open usando la funcion public.store_is_open
  ///   available_day usando el campo days de productos comparando con el dia actual usando el timezone
  ///   product_price usando la funcion product_price
  ///   distance comparando la distancia entre la store y el usuario
  ///   delivery_area usando el campo geom de la store comparando con el usuario

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
