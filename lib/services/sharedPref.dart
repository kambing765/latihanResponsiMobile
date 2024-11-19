import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  /// Simpan data pengguna saat login/register
  static Future<void> saveUser(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
  }

  static Future<void> deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }

  /// Periksa apakah pengguna sudah terdaftar
  static Future<bool> isRegistered(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    String? storedPassword = prefs.getString('password');

    return username == storedUsername && password == storedPassword;
  }

  /// Simpan daftar makanan favorit
  static Future<void> addFavorite(Map<String, dynamic> meal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favorites = prefs.getString('favorites');
    List<dynamic> favoriteMeals = favorites != null ? jsonDecode(favorites) : [];

    if (!favoriteMeals.any((item) => item['idMeal'] == meal['idMeal'])) {
      favoriteMeals.add(meal);
      prefs.setString('favorites', jsonEncode(favoriteMeals));
    }
  }

  /// Hapus makanan dari daftar favorit
  static Future<void> removeFavorite(String mealId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favorites = prefs.getString('favorites');
    List<dynamic> favoriteMeals = favorites != null ? jsonDecode(favorites) : [];

    favoriteMeals.removeWhere((meal) => meal['idMeal'] == mealId);
    prefs.setString('favorites', jsonEncode(favoriteMeals));
  }

  /// Ambil semua makanan favorit
  static Future<List<dynamic>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favorites = prefs.getString('favorites');
    return favorites != null ? jsonDecode(favorites) : [];
  }
}
