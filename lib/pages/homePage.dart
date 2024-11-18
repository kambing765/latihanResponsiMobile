import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latihanresponsi/pages/favoritePage.dart';
import 'package:latihanresponsi/pages/loginPage.dart';
import 'dart:convert';

import 'package:latihanresponsi/pages/mealDetails.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController areaController = TextEditingController();
  List<dynamic> meals = [];
  bool isLoading = false;

  Future<void> fetchMeals(String area) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          meals = data['meals'] ?? [];
        });
      } else {
        setState(() {
          meals = [];
        });
      }
    } catch (e) {
      setState(() {
        meals = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals by Area'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => FavoritePage()
                      ));
                    },
                    child: Text('halaman favorit')
                  ),
                  SizedBox(height: 20, width: 20,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => LoginPage()
                      ));
                    },
                    child: Text('Logout')
                  ),
                ],
              ),
            ),
            TextField(
              controller: areaController,
              decoration: InputDecoration(
                labelText: 'Enter Area (e.g., British)',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    fetchMeals(areaController.text.trim());
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (meals.isEmpty)
              const Center(
                child: Text(
                  'No meals found for this area.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          meal['strMealThumb'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(meal['strMeal']),
                        onTap: () {
                          // Navigate to detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MealDetailPage(mealId: meal['idMeal']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
