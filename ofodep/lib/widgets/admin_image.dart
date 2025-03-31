import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ofodep/repositories/image_repository.dart';

class AdminImage extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;
  final String? imageUrl;
  final String? clientId;
  final void Function(String) onImageUploaded;

  const AdminImage({
    super.key,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.contain,
    this.imageUrl,
    this.clientId,
    required this.onImageUploaded,
  });

  Future<void> pickImage(BuildContext context) async {
    debugPrint('clientId: $clientId');
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client ID is required to upload images."),
        ),
      );
      return;
    }

    final imageRepository = ImageRepository(clientId: clientId!);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      allowCompression: true,
      compressionQuality: 30,
    );

    if (result?.files.isEmpty ?? true) return;

    final pickedFile = result!.files.first;
    final bytes =
        kIsWeb ? pickedFile.bytes : await File(pickedFile.path!).readAsBytes();

    if (bytes == null || bytes.isEmpty) return;

    final uploadedUrl = await imageRepository.uploadImage(bytes);
    if (uploadedUrl != null) {
      onImageUploaded(uploadedUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pickImage(context),
      child: SizedBox(
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
            : Center(child: Icon(Icons.add_a_photo)),
      ),
    );
  }
}
