import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:latlong2/latlong.dart';

class ZonePolygon extends StatefulWidget {
  final Map<String, dynamic>? geom;
  const ZonePolygon({
    super.key,
    this.geom,
  });

  @override
  State<ZonePolygon> createState() => _ZonePolygonState();
}

class _ZonePolygonState extends State<ZonePolygon> {
  late PolyEditor polyEditor;
  late PolygonGeometry polygonGeometry;

  @override
  void initState() {
    polygonGeometry = PolygonGeometry.fromGeom(widget.geom);

    polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: polygonGeometry.points,
      pointIcon: const Icon(Icons.crop_square, size: 23),
      intermediateIcon: const Icon(Icons.lens, size: 15, color: Colors.grey),
      callbackRefresh: (LatLng? _) => {setState(() {})},
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final polygons = <Polygon>[];

    final testPolygon = polygonGeometry.polygon;

    if (polygonGeometry.points.isNotEmpty) {
      polygons.add(testPolygon);
    }

    return FlutterMap(
      options: MapOptions(
        onTap: (_, ll) {
          polyEditor.add(testPolygon.points, ll);
        },
        initialCenter: polygonGeometry.center ?? LatLng(45.5231, -122.6765),
        initialZoom: 10,
      ),
      children: [
        TileLayer(
          // Bring your own tiles
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ofodep',
        ),
        PolygonLayer(polygons: polygons),
        DragMarkers(markers: polyEditor.edit()),
      ],
    );
  }
}

class PolygonGeometry {
  final List<LatLng> points;

  PolygonGeometry({List<LatLng>? points}) : points = points ?? [];

  // Constructor a partir de un Map (GeoJSON) o instancia vacía si es nulo o inválido.
  factory PolygonGeometry.fromGeom(Map<String, dynamic>? geom) {
    if (geom == null || geom['type'] != 'Polygon') {
      return PolygonGeometry();
    }
    final List<LatLng> points = [];
    final coordinates = geom['coordinates'];
    if (coordinates is List &&
        coordinates.isNotEmpty &&
        coordinates[0] is List) {
      final List outerRing = coordinates[0];
      for (var point in outerRing) {
        if (point is List && point.length >= 2) {
          // Convertir de [longitud, latitud] a LatLng(latitud, longitud)
          points.add(LatLng(point[1], point[0]));
        }
      }
    }
    return PolygonGeometry(points: points);
  }

  // Método para convertir la instancia a un Map con formato GeoJSON
  Map<String, dynamic> get toGeoJson {
    return {
      'type': 'Polygon',
      'crs': {
        'type': 'name',
        'properties': {'name': 'EPSG:4326'},
      },
      'coordinates': [
        points.map((latlng) => [latlng.longitude, latlng.latitude]).toList()
      ],
    };
  }

  // Metodo obtener el objeto Polygon de FlutterMap
  Polygon get polygon {
    return Polygon(
      points: points,
      color: Colors.blue.withAlpha(80),
      borderColor: Colors.blueAccent,
      borderStrokeWidth: 2,
    );
  }

  // Getter para obtener el centro del polígono (promedio de las coordenadas)
  LatLng? get center {
    if (points.isEmpty) return null;
    double sumLat = 0.0;
    double sumLng = 0.0;
    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }
}
