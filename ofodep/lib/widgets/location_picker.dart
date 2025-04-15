import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ofodep/models/location_model.dart';
import 'package:ofodep/repositories/location_repository.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/custom_list_view.dart';

class LocationPicker extends StatefulWidget {
  final String title;
  final void Function()? onBack;
  final void Function()? onSave;
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(LatLng) onLocationChanged;
  final double initialZoom;
  final String? countryCode;
  const LocationPicker({
    super.key,
    required this.title,
    this.onBack,
    this.onSave,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
    this.initialZoom = 15,
    required this.countryCode,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng currentLocation;
  late double initialZoom;
  final MapController controller = MapController();

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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        debugPrint('onPopInvokedWithResult: $didPop');
        if (!didPop) {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            context.pop();
          }
        }
      },
      child: Stack(
        children: [
          FlutterMap(
            mapController: controller,
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
            bottom: FloatingMenuButton.size * 8,
            right: FloatingMenuButton.size,
            child: Column(
              children: [
                IconButton.filledTonal(
                  onPressed: () => controller.move(
                    controller.camera.center,
                    controller.camera.zoom + 1.0,
                  ),
                  icon: const Icon(Icons.add),
                  tooltip: 'Acercar',
                ),
                gap,
                IconButton.filledTonal(
                  onPressed: () => controller.move(
                    controller.camera.center,
                    controller.camera.zoom - 1.0,
                  ),
                  icon: const Icon(Icons.remove),
                  tooltip: 'Alejar',
                ),
                gap,
                if (widget.countryCode != null)
                  IconButton.filledTonal(
                    onPressed: () => showBottomSheet(
                      context: context,
                      builder: (context) => SearchDirection(
                        countryCode: widget.countryCode!,
                        onLocationSelected: (location) {
                          controller.move(
                            location,
                            controller.camera.zoom + 1.0,
                          );
                        },
                      ),
                    ),
                    icon: const Icon(Icons.search),
                    tooltip: 'Buscar',
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: FloatingMenuButton.size * 8,
            left: FloatingMenuButton.size,
            child: Text(
              'Selecciona tu ubicación en el mapa',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.black),
            ),
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
      ),
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

class SearchDirection extends StatefulWidget {
  final String countryCode;
  final void Function(LatLng) onLocationSelected;
  const SearchDirection({
    super.key,
    required this.countryCode,
    required this.onLocationSelected,
  });

  @override
  State<SearchDirection> createState() => _SearchDirectionState();
}

class _SearchDirectionState extends State<SearchDirection> {
  final LocationRepository repository = LocationRepository();
  final TextEditingController controller = TextEditingController();
  List<LocationModel> locations = [];
  Timer? debounce;

  @override
  void initState() {
    super.initState();

    controller.addListener(getLocations);
  }

  @override
  void dispose() {
    controller.removeListener(getLocations);
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> getLocations() async {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(Duration(milliseconds: 500), () async {
      String query = controller.text;
      if (query.trim().isEmpty) {
        return;
      }
      final response = await repository.searchLocations(
        countryCode: widget.countryCode,
        query: controller.text,
      );
      if (mounted) {
        setState(() {
          locations = response;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.8;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: CustomListView(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Buscar',
            ),
          ),
          if (locations.isNotEmpty)
            ...locations.map(
              (location) {
                return ListTile(
                  title: Text([
                    location.street ?? '',
                    location.city ?? '',
                    location.state ?? '',
                    location.zipCode,
                  ].join(' ').trim()),
                  subtitle: Text([
                    location.latitude,
                    location.longitude,
                  ].map((e) => e.toStringAsFixed(4)).join(', ')),
                  onTap: () {
                    widget.onLocationSelected(
                      LatLng(
                        location.latitude,
                        location.longitude,
                      ),
                    );
                    context.pop();
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
