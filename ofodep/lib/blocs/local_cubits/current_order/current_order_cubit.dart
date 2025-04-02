import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/order_model.dart';

/// Estados genéricos para un cubit CURRENT_ORDER.
abstract class CurrentOrderState {}

/// Estado de la orden actual vacío.
class CurrentOrderEmpty extends CurrentOrderState {}

/// Estado de la orden actual inicializada.
class CurrentOrderInitialized extends CurrentOrderState {
  final OrderModel order;
  final String? errorMessage;
  CurrentOrderInitialized({
    required this.order,
    this.errorMessage,
  });

  /// Crea una copia modificada del estado.
  /// [order] modelo original
  /// [errorMessage] mensaje de error
  CurrentOrderInitialized copyWith({
    OrderModel? order,
    String? errorMessage,
  }) {
    return CurrentOrderInitialized(
      order: order ?? this.order,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Estado de la orden actual siendo cargada.
class CurrentOrderLoading extends CurrentOrderState {
  final OrderModel order;
  CurrentOrderLoading(this.order);
}

class CurrentOrderCubit extends Cubit<CurrentOrderState> {
  CurrentOrderCubit() : super(CurrentOrderEmpty());
}
