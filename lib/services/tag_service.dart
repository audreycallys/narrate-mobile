import 'dart:convert';
import 'package:http/http.dart' as http;

class TagService {
  static const String baseUrl =
      'https://rgxqmjcn-5000.asse.devtunnels.ms/api/tags';

  static Future<List> getTags(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl?categoryId=$categoryId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['tags'];
    } else {
      throw Exception('Tag gagal diambil');
    }
  }

  static Future<Map> createTag({
    required int categoryId,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'categoryId': categoryId, 'name': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final responseData = data['data'];

      if (responseData['tag'] != null) {
        return responseData['tag'];
      }

      return responseData;
    } else {
      throw Exception('Tag gagal dibuat');
    }
  }
}
