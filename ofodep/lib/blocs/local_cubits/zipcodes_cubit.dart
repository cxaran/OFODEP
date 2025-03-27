import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/location_model.dart';
import 'package:ofodep/repositories/location_repository.dart';

class ZipcodesState {
  final List<LocationModel> searchResults;
  final String? errorMessage;

  ZipcodesState({
    this.searchResults = const [],
    this.errorMessage,
  });

  ZipcodesState copyWith({
    List<LocationModel>? searchResults,
    String? errorMessage,
  }) {
    return ZipcodesState(
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ZipcodesCubit extends Cubit<ZipcodesState> {
  final LocationRepository repository;

  ZipcodesCubit({LocationRepository? repository})
      : repository = repository ?? LocationRepository(),
        super(ZipcodesState());

  /// Busca ubicaciones por texto
  Future<void> searchZipcodes(String query) async {
    emit(ZipcodesState());
    try {
      final results = await repository.searchLocations(query);

      emit(ZipcodesState(searchResults: results));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: "No se pudieron cargar los resultados",
        ),
      );
    }
  }
}
