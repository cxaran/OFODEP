import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/models/order_product_model.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/product_repository.dart';

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

class CurrentProductCubit extends Cubit<CurrentProductState> {
  final ProductRepository productRepository;

  CurrentProductCubit({
    ProductRepository? productRepository,
  })  : productRepository = productRepository ?? ProductRepository(),
        super(CurrentProductInitial());

  Future<void> load() async {}
}
