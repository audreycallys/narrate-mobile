import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileService {
  static const String baseUrl =
      'https://rgxqmjcn-5000.asse.devtunnels.ms/api/profile';

  static Future<Map> getProfile() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final Map profile = Map<String, dynamic>.from(
        data['data']['profile'] ?? data['data'],
      );

      profile['imageUrl'] = profile['avatarUrl'];
      profile['imagePublicId'] = profile['avatarPublicId'];

      return profile;
    }

    throw Exception('Data profil gagal diambil');
  }

  static Future<bool> updateProfile({
    required String name,
    required String email,
    required String bio,
    XFile? image,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse(baseUrl));

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['bio'] = bio;

    if (image != null) {
      final imageBytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: image.name),
      );
    }

    final response = await request.send();

    return response.statusCode == 200;
  }
}
