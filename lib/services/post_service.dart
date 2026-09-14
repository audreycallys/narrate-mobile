import 'dart:convert';
import 'package:http/http.dart' as http;

class PostService {
  static Future<List> getPosts() async {
    final response = await http.get(
      Uri.parse('https://rgxqmjcn-5000.asse.devtunnels.ms/api/posts'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['posts'];
    } else {
      throw Exception('Data artikel gagal diambil');
    }
  }

  static Future<bool> createPost({
    required String title,
    required String content,
    required int categoryId,
    required String status,
    required List<int> tagIds,
    required String imagePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://rgxqmjcn-5000.asse.devtunnels.ms/api/posts'),
    );

    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['categoryId'] = categoryId.toString();
    request.fields['status'] = status;
    request.fields['tagIds'] = jsonEncode(tagIds);

    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List> getPostsByStatus(String status) async {
    final response = await http.get(
      Uri.parse(
        'https://rgxqmjcn-5000.asse.devtunnels.ms/api/posts?status=$status',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['posts'];
    }

    throw Exception('Data artikel gagal diambil');
  }

  static Future<bool> updatePost({
    required int postId,
    required String title,
    required String content,
    required int categoryId,
    required String status,
    required List<int> tagIds,
    String? imagePath,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('https://rgxqmjcn-5000.asse.devtunnels.ms/api/posts/$postId'),
    );

    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['categoryId'] = categoryId.toString();
    request.fields['status'] = status;
    request.fields['tagIds'] = jsonEncode(tagIds);

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();

    return response.statusCode == 200;
  }

  static Future<bool> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('https://rgxqmjcn-5000.asse.devtunnels.ms/api/posts/$postId'),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
