import 'package:flutter/material.dart';

class PreviewImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double radius;
  final BoxFit fit;
  const PreviewImage({
    super.key,
    this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.radius = 0,
    this.fit = BoxFit.contain,
  });

  const PreviewImage.mini({
    super.key,
    this.imageUrl,
  })  : width = 40,
        height = 40,
        radius = 10,
        fit = BoxFit.cover;

  const PreviewImage.medium({
    super.key,
    this.imageUrl,
  })  : width = 200,
        height = 200,
        radius = 20,
        fit = BoxFit.cover;

  const PreviewImage.large({
    super.key,
    this.imageUrl,
  })  : width = double.infinity,
        height = 300,
        radius = 30,
        fit = BoxFit.cover;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
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
      ),
    );
  }
}
