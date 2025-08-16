import 'package:carpooling_app/data/api_services/mapbox_srearchPlacesApi.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';

class MapboxSrearchplacesrepo {
  MapboxSrearchplacesapi mapboxSrearchplacesapi = MapboxSrearchplacesapi();

  Future<List<MapboxPlace>> getSerachPlaces(
    String query, {
    String country = 'EG',
    int limit = 5,
    String language = 'ar',
    String? proximity, // إضافة معامل proximity اختياري
  }) async {
    try {
      return mapboxSrearchplacesapi.searchPlaces(
        query,
        country: country,
        limit: limit,
        language: language,
        proximity: proximity, // تمرير proximity للـ API
      );
    } catch (e) {
     throw Exception('Error searching places: $e');
    }
  }
}