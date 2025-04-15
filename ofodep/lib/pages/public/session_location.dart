import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ofodep/blocs/local_cubits/location_cubit.dart';
import 'package:ofodep/models/location_model.dart';
import 'package:ofodep/repositories/location_repository.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/location_picker.dart';

class SessionLocation extends StatefulWidget {
  const SessionLocation({super.key});

  @override
  State<SessionLocation> createState() => _SessionLocationState();
}

class _SessionLocationState extends State<SessionLocation> {
  late LatLng currentLocation;
  late double initialZoom;
  final MapController controller = MapController();
  LocationModel? location;

  @override
  void initState() {
    super.initState();
    final location = context.read<LocationCubit>().state;
    if (location is LocationLoaded) {
      currentLocation = LatLng(
        location.location.latitude,
        location.location.longitude,
      );
      initialZoom = 13;
    } else {
      currentLocation = LatLng(20, -100);
      initialZoom = 5;
    }
    getLocation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getLocation() async {
    setState(() => location = null);
    location = await LocationRepository().getLocationFromCoordinates(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void updateLocation() {
    if (location != null) {
      context.read<LocationCubit>().updateLocationManual(
            latitude: location!.latitude,
            longitude: location!.longitude,
            zipCode: location!.zipCode,
            street: location!.street,
            city: location!.city,
            state_: location!.state,
            country: location!.country,
            countryCode: location!.countryCode,
            timezone: location!.timezone,
          );
      context.pop();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
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
                  getLocation();
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
                        getLocation();
                      },
                    ),
                  ],
                ),
              ],
            ),
            FloatingMenuButton(
              title: 'Selecciona tu ubicación',
              onBack: () => context.pop(),
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
                  IconButton.filledTonal(
                    onPressed: () => showBottomSheet(
                      context: context,
                      builder: (context) => SearchDirectionCurrent(
                        onLocationSelected: (value) {
                          currentLocation = LatLng(
                            value.latitude,
                            value.longitude,
                          );
                          controller.move(currentLocation, 13);
                          setState(() => location = value);
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
                onPressed: location == null ? null : updateLocation,
                label: Text('Guardar ${location?.city ?? ''}'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SearchDirectionCurrent extends StatefulWidget {
  final void Function(LocationModel) onLocationSelected;
  const SearchDirectionCurrent({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<SearchDirectionCurrent> createState() => _SearchDirectionCurrentState();
}

class _SearchDirectionCurrentState extends State<SearchDirectionCurrent> {
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
      final response = await repository.searchPlace(controller.text);
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
                    location.city ?? '',
                    location.state ?? '',
                    location.zipCode ?? '',
                    location.country ?? '',
                    location.countryCode,
                  ].join(' ').trim()),
                  subtitle: Text([
                    location.latitude,
                    location.longitude,
                  ].map((e) => e.toStringAsFixed(4)).join(', ')),
                  onTap: () {
                    widget.onLocationSelected(location);
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
