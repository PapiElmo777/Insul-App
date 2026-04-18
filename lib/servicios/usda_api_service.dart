import 'dart:convert';
import 'package:http/http.dart' as http;

class UsdaApiService {
  static const String _apiKey = 'DEMO_KEY';
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  static Future<List<Map<String, dynamic>>> buscarAlimentos(String query) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse('$_baseUrl/foods/search?api_key=$_apiKey&query=$query&dataType=Foundation,SR%20Legacy&pageSize=15');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> foods = data['foods'];

        return foods.map((food) {
          final nutrients = food['foodNutrients'] as List<dynamic>? ?? [];
          double carbos = 0.0;
          for (var n in nutrients) {
            if (n['nutrientId'] == 1005 || n['nutrientName'].toString().toLowerCase().contains('carbohydrate')) {
              carbos = (n['value'] as num).toDouble();
              break;
            }
          }

          return {
            'fdcId': food['fdcId'],
            'nombre': food['description'],
            'carbos_por_100g': carbos,
          };
        }).toList();
      }
    } catch (e) {
      print('Error conectando con USDA API: $e');
    }
    return [];
  }
}