import 'package:carpooling_app/data/api_services/mapbox_srearchPlacesApi.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';


class MapboxSrearchplacesrepo {
  MapboxSrearchplacesapi mapboxSrearchplacesapi = MapboxSrearchplacesapi();

  Future<List<MapboxPlace>> getSerachPlaces(
    String query, {
    String country = 'EG',
    int limit = 5,
    String language = 'ar',
  }) async {
    try {
      return mapboxSrearchplacesapi.searchPlaces(
        query,
        country: country,
        limit: limit,
        language: language,
      );
    } catch (e) {
     throw Exception('Error searching places: $e');
    }
  }
}
