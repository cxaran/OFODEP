import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageRepository {
  final String clientId;
  // final String clientSecret;

  ImageRepository({
    required this.clientId,
    // required this.clientSecret,
  });

  Future<String?> uploadImage(List<int> imageBytes) async {
    final url = Uri.parse("https://api.imgur.com/3/image");

    final base64Image = base64Encode(imageBytes);

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Client-ID $clientId",
        },
        body: {
          "image": base64Image,
          "type": "base64",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data["data"]["link"];
      } else {
        debugPrint("Error al subir la imagen: ${response.body}");
      }
    } on Exception catch (e) {
      debugPrint("Error al subir la imagen: $e");
    }
    return null;
  }
}
