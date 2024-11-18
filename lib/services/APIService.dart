import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchMealsByArea(String area) async {
  final response = await http.get(Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area'));
  if (response.statusCode == 200) {
    final meals = jsonDecode(response.body)['meals'];
    return meals;
  } else {
    throw Exception('Failed to fetch meals');
  }
}

Future<Map<String, dynamic>> fetchMealDetail(String mealId) async {
  final response = await http.get(Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId'));
  if (response.statusCode == 200) {
    final mealDetail = jsonDecode(response.body)['meals'][0];
    return mealDetail;
  } else {
    throw Exception('Failed to fetch meal detail');
  }
}
