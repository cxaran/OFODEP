import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/local_cubits/location_cubit.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoaded) {
          return LocationIcon(
            icon: Icons.location_on,
            label: state.location.city ?? '',
          );
        } else if (state is LocationError) {
          return LocationIcon(
            icon: Icons.location_off,
            color: Theme.of(context).colorScheme.error,
          );
        } else if (state is LocationLoading) {
          return LocationIcon(
            icon: Icons.location_on,
            label: '',
          );
        } else {
          // Estado inicial u otro no manejado
          return SizedBox.shrink();
        }
      },
    );
  }
}

class LocationIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String label;
  const LocationIcon({
    super.key,
    required this.icon,
    this.color,
    this.label = '',
  });

  Future<void> onRefresh(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 145, maxHeight: 60),
      child: TextButton.icon(
        onPressed: () => onRefresh(context),
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
