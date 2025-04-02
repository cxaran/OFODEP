import 'package:flutter/material.dart';

class PreviewImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  const PreviewImage({
    super.key,
    this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: fit,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_not_supported_rounded,
                color: Colors.grey,
              ),
            )
          : Center(child: Icon(Icons.photo)),
    );
  }
}
