import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PostService {
  static const String baseUrl =
      'https://rgxqmjcn-5000.asse.devtunnels.ms/api/posts';

  static Future<List> getPosts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['posts'];
    }

    throw Exception('Data artikel gagal diambil');
  }

  static Future<bool> createPost({
    required String title,
    required String content,
    required int categoryId,
    required String status,
    required List<int> tagIds,
    required XFile image,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['categoryId'] = categoryId.toString();
      request.fields['status'] = status;
      request.fields['tagIds'] = jsonEncode(tagIds);

      final imageBytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: image.name),
      );

      final streamedResponse = await request.send();

      final responseBody = await streamedResponse.stream.bytesToString();

      debugPrint('CREATE POST STATUS: ${streamedResponse.statusCode}');
      debugPrint('CREATE POST BODY: $responseBody');

      return streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201;
    } catch (e) {
      debugPrint('CREATE POST ERROR: $e');
      rethrow;
    }
  }

  static Future<List> getPostsByStatus(String status) async {
    final response = await http.get(Uri.parse('$baseUrl?status=$status'));

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
    XFile? image,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$postId'));

    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['categoryId'] = categoryId.toString();
    request.fields['status'] = status;
    request.fields['tagIds'] = jsonEncode(tagIds);

    if (image != null) {
      final imageBytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: image.name),
      );
    }

    final streamedResponse = await request.send();

    final responseBody = await streamedResponse.stream.bytesToString();

    debugPrint('UPDATE POST STATUS: ${streamedResponse.statusCode}');
    debugPrint('UPDATE POST BODY: $responseBody');

    return streamedResponse.statusCode == 200;
  }

  static Future<bool> deletePost(int postId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$postId'));

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
