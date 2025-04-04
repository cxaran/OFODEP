import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';

class LocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(LatLng) onLocationChanged;
  final double initialZoom;
  const LocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
    this.initialZoom = 15,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng currentLocation;
  late double initialZoom;

  @override
  void initState() {
    super.initState();
    // Si no se provee ubicación inicial, se asigna una ubicación por defecto.
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      currentLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      initialZoom = widget.initialZoom;
    } else {
      currentLocation = LatLng(20, -100);
      initialZoom = 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: initialZoom,
        onTap: (_, tappedPoint) {
          setState(() {
            currentLocation = tappedPoint;
          });
          widget.onLocationChanged(tappedPoint);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'Mozilla/5.0',
        ),
        DragMarkers(
          markers: [
            DragMarker(
              point: currentLocation,
              size: const Size(40, 40),
              builder: (context, point, marker) => const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
              onDragEnd: (details, newPoint) {
                setState(() {
                  currentLocation = newPoint;
                });
                widget.onLocationChanged(newPoint);
              },
            ),
          ],
        ),
      ],
    );
  }
}
