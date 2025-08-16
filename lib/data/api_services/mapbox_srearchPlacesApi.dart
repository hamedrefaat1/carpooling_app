import 'dart:convert';

import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:http/http.dart' as http;

class MapboxSrearchplacesapi {
  static const String _accessToken = 'REMOVED';
  static const String _baseUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  Future<List<MapboxPlace>> searchPlaces(
    String query, {
    String country = 'EG',
    int limit = 5,
    String language = 'ar',
    String? proximity, 
  }) async {
    try {
      if (query.length < 3) {
        return [];
      }

      final url = Uri.parse(
        '$_baseUrl/$query.json'
        '?access_token=$_accessToken'
        '&country=$country'
        '&types=place,locality,neighborhood,address,poi'
        '&limit=$limit'
        '&language=$language'
        '&autocomplete=true'
        '${proximity != null ? '&proximity=$proximity' : ''}', 
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data["features"] as List;

        return features
            .map((feature) => MapboxPlace.fromJson(feature))
            .toList();
      } else {
        throw Exception('Mapbox API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }
}