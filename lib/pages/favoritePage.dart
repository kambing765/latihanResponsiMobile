import 'package:flutter/material.dart';
import 'package:latihanresponsi/pages/mealDetails.dart';
import 'package:latihanresponsi/services/sharedPref.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<dynamic> favoriteMeals = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await SharedPreferenceService.getFavorites();
    setState(() {
      favoriteMeals = favorites;
    });
  }

  void removeFavorite(String mealId) async {
    await SharedPreferenceService.removeFavorite(mealId);
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoriteMeals.isEmpty
          ? const Center(child: Text('No favorites added yet'))
          : ListView.builder(
              itemCount: favoriteMeals.length,
              itemBuilder: (context, index) {
                final meal = favoriteMeals[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(meal['strMealThumb']),
                    title: Text(meal['strMeal']),
                    onTap: (){
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => MealDetailPage(mealId: meal['idMeal']))
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeFavorite(meal['idMeal']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
