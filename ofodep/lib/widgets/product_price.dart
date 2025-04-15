import 'package:flutter/material.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/utils/constants.dart';

class ProductPrice extends StatelessWidget {
  final ProductModel product;
  const ProductPrice({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    if (product.productPrice != product.regularPrice) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mostrar el precio de oferta en negrita.
          Text(
            currencyFormatter.format(product.productPrice),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            currencyFormatter.format(product.regularPrice),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(decoration: TextDecoration.lineThrough),
          ),
        ],
      );
    }
    return Text(
      currencyFormatter.format(product.regularPrice),
      style: Theme.of(context).textTheme.titleSmall,
    );
  }
}
