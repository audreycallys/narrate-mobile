import 'dart:convert';
import 'package:http/http.dart' as http;

class PostService {
  static Future<List> getPosts() async {
    final response = await http.get(
      Uri.parse(
        'https://rgxqmjcn-5000.asse.devtunnels.ms/api/posts',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['posts'];
    } else {
      throw Exception('Data artikel gagal diambil');
    }
  }
}