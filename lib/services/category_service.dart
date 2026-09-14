import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  static Future<List> getCategories() async {
    final response = await http.get(
      Uri.parse('https://rgxqmjcn-5000.asse.devtunnels.ms/api/categories'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['categories'];
    } else {
      throw Exception('Data kategori gagal diambil');
    }
  }
}
