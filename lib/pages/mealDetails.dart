import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latihanresponsi/services/APIService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealDetailPage extends StatefulWidget {
  final String mealId;

  const MealDetailPage({Key? key, required this.mealId}) : super(key: key);

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  /// Mengecek apakah makanan sudah ada di daftar favorit
  Future<void> checkFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favorites = prefs.getString('favorites');
    List<dynamic> favoriteMeals = favorites != null ? jsonDecode(favorites) : [];

    setState(() {
      isFavorite = favoriteMeals.any((meal) => meal['idMeal'] == widget.mealId);
    });
  }

  /// Menambah makanan ke daftar favorit
  Future<void> addFavorite(Map<String, dynamic> meal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favorites = prefs.getString('favorites');
    List<dynamic> favoriteMeals = favorites != null ? jsonDecode(favorites) : [];

    favoriteMeals.add(meal);
    await prefs.setString('favorites', jsonEncode(favoriteMeals));

    setState(() {
      isFavorite = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to Favorites')),
    );
  }

  /// Menghapus makanan dari daftar favorit
  Future<void> removeFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favorites = prefs.getString('favorites');
    List<dynamic> favoriteMeals = favorites != null ? jsonDecode(favorites) : [];

    favoriteMeals.removeWhere((meal) => meal['idMeal'] == widget.mealId);
    await prefs.setString('favorites', jsonEncode(favoriteMeals));

    setState(() {
      isFavorite = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from Favorites')),
    );
  }

  /// Mengambil pasangan `strIngredient` dan `strMeasure` dari respons API.
  Map<String, String> getIngredientsAndMeasures(Map<String, dynamic> mealDetail) {
    final ingredientsAndMeasures = <String, String>{};

    for (int i = 1; i <= 20; i++) {
      final ingredient = mealDetail['strIngredient$i'];
      final measure = mealDetail['strMeasure$i'];

      if (ingredient != null && ingredient.isNotEmpty && measure != null && measure.isNotEmpty) {
        ingredientsAndMeasures[ingredient] = measure;
      }
    }

    return ingredientsAndMeasures;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMealDetail(widget.mealId), // Menggunakan APIService.dart
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final meal = snapshot.data!;
            final ingredientsAndMeasures = getIngredientsAndMeasures(meal);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama makanan
                  Text(
                    meal['strMeal'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Tag makanan
                  Text(
                    'Tags: ${meal['strTags'] ?? 'No Tags'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Gambar makanan
                  Center(
                    child: Image.network(
                      meal['strMealThumb'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ingredients & Measures
                  const Text(
                    'Ingredients & Measures:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...ingredientsAndMeasures.entries.map((entry) => Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 16),
                      )),

                  const SizedBox(height: 20),

                  // Tombol Favorit
                  Center(
                    child: IconButton(
                      onPressed: () {
                        if (isFavorite) {
                          removeFavorite();
                        } else {
                          addFavorite(meal);
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
