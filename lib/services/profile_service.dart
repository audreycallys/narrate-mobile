import 'dart:convert';

import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl =
      'https://rgxqmjcn-5000.asse.devtunnels.ms/api/profile';

  static Future<Map> getProfile() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['profile'] ?? data['data'];
    }

    throw Exception('Data profil gagal diambil');
  }

  static Future<bool> updateProfile({
    required String name,
    required String email,
    required String bio,
    String? imagePath,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse(baseUrl));

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['bio'] = bio;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();

    return response.statusCode == 200;
  }
}
