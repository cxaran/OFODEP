import 'package:ofodep/models/order_product_model.dart';
import 'package:ofodep/models/product_model.dart';

/// Estados genéricos para un cubit CURRENT_PRODUCT.
abstract class CurrentProductState {}

/// Estado de la orden actual inicial.
class CurrentProductInitial extends CurrentProductState {}

/// Estado de la orden actual cargando.
class CurrentProductLoaded extends CurrentProductState {
  final ProductModel product;
  final OrderProductModel orderProduct;

  CurrentProductLoaded({
    required this.product,
    required this.orderProduct,
  });

  /// Crea una copia modificada del estado.
  /// [product] modelo original
  /// [orderProduct] modelo original
  CurrentProductLoaded copyWith({
    ProductModel? product,
    OrderProductModel? orderProduct,
  }) =>
      CurrentProductLoaded(
        product: product ?? this.product,
        orderProduct: orderProduct ?? this.orderProduct,
      );
}

///
