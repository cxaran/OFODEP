import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:latlong2/latlong.dart';
import 'package:ofodep/widgets/location_picker.dart';

class ZonePolygon extends StatefulWidget {
  final String title;
  final void Function()? onBack;
  final void Function()? onSave;
  final Map<String, dynamic>? geom;
  final Function(Map<String, dynamic>) onGeomChanged;
  final double centerLatitude;
  final double centerLongitude;
  final double maxDistance;
  const ZonePolygon({
    super.key,
    required this.title,
    this.onBack,
    this.onSave,
    this.geom,
    required this.onGeomChanged,
    required this.centerLatitude,
    required this.centerLongitude,
    this.maxDistance = 5000,
  });

  @override
  State<ZonePolygon> createState() => _ZonePolygonState();
}

class _ZonePolygonState extends State<ZonePolygon> {
  late PolyEditor polyEditor;
  late PolygonGeometry polygonGeometry;

  @override
  void initState() {
    polygonGeometry = PolygonGeometry.fromGeom(
      widget.geom,
      LatLng(
        widget.centerLatitude,
        widget.centerLongitude,
      ),
    );

    polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: polygonGeometry.points,
      pointIcon: const Icon(
        Icons.square,
        size: 15,
        color: Colors.orange,
      ),
      intermediateIcon: const Icon(
        Icons.lens,
        size: 10,
        color: Colors.orangeAccent,
      ),
      callbackRefresh: (LatLng? _) => setState(
        () => widget.onGeomChanged(
          polygonGeometry.toGeMap,
        ),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Polygon> polygons = [];

    final testPolygon = polygonGeometry.polygon;

    if (polygonGeometry.points.isNotEmpty) {
      polygons.add(testPolygon);
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            onTap: (_, tappedPoint) {
              if (polygonGeometry.distance(tappedPoint) > widget.maxDistance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('max distance:${widget.maxDistance}'),
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              }
              polyEditor.add(testPolygon.points, tappedPoint);
            },
            initialCenter: polygonGeometry.center,
            initialZoom: polygonGeometry.zoom ?? 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ofodep',
            ),
            PolygonLayer(polygons: polygons),
            DragMarkers(
              markers: polyEditor.edit().map((marker) {
                return DragMarker(
                  size: marker.size,
                  point: marker.point,
                  builder: marker.builder,
                  onDragUpdate: (details, position) {
                    if (polygonGeometry.distance(position) <=
                        widget.maxDistance) {
                      marker.onDragUpdate?.call(details, position);
                    } else {
                      setState(() {});
                    }
                  },
                  onDragStart: (details, position) => marker.onDragStart?.call(
                    details,
                    position,
                  ),
                  onDragEnd: (details, position) => marker.onDragEnd?.call(
                    details,
                    position,
                  ),
                  onLongPress: (details) => marker.onLongPress?.call(details),
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(widget.centerLatitude, widget.centerLongitude),
                  width: 20,
                  height: 20,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
        FloatingMenuButton(
          title: widget.title,
          onBack: widget.onBack,
        ),
        Positioned(
          bottom: FloatingMenuButton.size,
          right: FloatingMenuButton.size,
          left: FloatingMenuButton.size,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            onPressed: widget.onSave,
            label: Text('Guardar'),
          ),
        )
      ],
    );
  }
}

class PolygonGeometry {
  final List<LatLng> points;
  final LatLng center;

  PolygonGeometry({List<LatLng>? points, required this.center})
      : points = points ?? [];

  // Constructor a partir de un Map (GeoJSON) o instancia vacía si es nulo o inválido.
  factory PolygonGeometry.fromGeom(Map<String, dynamic>? geom, LatLng center) {
    if (geom == null || geom['type'] != 'Polygon') {
      return PolygonGeometry(center: center);
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
    return PolygonGeometry(points: points, center: center);
  }

  // Método para convertir la instancia a un Map con formato GeoJSON
  Map<String, dynamic> get toGeMap {
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

  // Método para calcular la distancia entre un punto y el centro
  double distance(LatLng point) {
    final distanceCalculator = Distance();
    return distanceCalculator.as(LengthUnit.Meter, center, point);
  }

  // Getter para obtener el zoom para visualizar el poligono
  double? get zoom {
    if (points.isEmpty) return null;

    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);
    final maxDiff = (lats.reduce((a, b) => a > b ? a : b) -
                    lats.reduce((a, b) => a < b ? a : b))
                .clamp(0.0, double.infinity)
                .compareTo((lngs.reduce((a, b) => a > b ? a : b) -
                    lngs.reduce((a, b) => a < b ? a : b))) <
            0
        ? (lngs.reduce((a, b) => a > b ? a : b) -
            lngs.reduce((a, b) => a < b ? a : b))
        : (lats.reduce((a, b) => a > b ? a : b) -
            lats.reduce((a, b) => a < b ? a : b));

    return maxDiff < 0.005
        ? 16
        : maxDiff < 0.01
            ? 15
            : maxDiff < 0.05
                ? 14
                : maxDiff < 0.1
                    ? 13
                    : maxDiff < 0.5
                        ? 12
                        : maxDiff < 1.0
                            ? 10
                            : 8;
  }
}
