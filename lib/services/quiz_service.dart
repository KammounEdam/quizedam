import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizService {
  static const String baseUrl = 'https://opentdb.com';

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['trivia_categories']);
    }
    throw Exception('Failed to load categories');
  }

  Future<Map<String, dynamic>> getQuestions({
    required int amount,
    required int categoryId,
    required String difficulty,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api.php?amount=$amount&category=$categoryId&difficulty=$difficulty&type=multiple',
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load questions');
  }
}
