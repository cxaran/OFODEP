import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';

class LocationPicker extends StatefulWidget {
  final String title;
  final void Function()? onBack;
  final void Function()? onSave;
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(LatLng) onLocationChanged;
  final double initialZoom;
  const LocationPicker({
    super.key,
    required this.title,
    this.onBack,
    this.onSave,
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
    return Stack(
      children: [
        FlutterMap(
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

class FloatingMenuButton extends StatelessWidget {
  final String title;
  final void Function()? onBack;

  const FloatingMenuButton({
    super.key,
    required this.title,
    this.onBack,
  });

  static const double size = 8;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: size,
      top: size,
      child: SafeArea(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(size / 2),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: size),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: size),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
