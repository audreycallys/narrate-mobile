import 'dart:convert';
import 'package:http/http.dart' as http;

class SavedService {
  static const String baseUrl =
      'https://rgxqmjcn-5000.asse.devtunnels.ms/api/saved';

  // GET SAVED
  static Future<List> getSavedPosts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['savedPosts'];
    }

    throw Exception('Data tersimpan gagal diambil');
  }

  // SIMPAN ARTIKEL
  static Future<bool> savePost(int postId) async {
    final response = await http.post(Uri.parse('$baseUrl/$postId'));

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // HAPUS DARI TERSIMPAN
  static Future<bool> deleteSavedPost(int postId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$postId'));

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
