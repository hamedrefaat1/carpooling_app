// إصلاح PlaceSearchCubit
import 'dart:async';
import 'package:carpooling_app/business_logic/cubits/PlaceSearchCubit/place_search_states.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:carpooling_app/data/repositories/mapbox_srearchPlacesRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaceSearchCubit extends Cubit<PlaceSearchState> {
  final MapboxSrearchplacesrepo _mapboxSrearchplacesrepo = MapboxSrearchplacesrepo();
  MapboxPlace? _selectedPlace;

  PlaceSearchCubit() : super(PlaceSearchInitial());

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      emit(PlaceSearchInitial());
      return;
    }
    if (query.length < 3) {
      return;
    }

    emit(PlaceSearchLoading());
    try {
      final places = await _mapboxSrearchplacesrepo.getSerachPlaces(query);
      
      if (places.isEmpty) {
        emit(PlaceSearchError('No places found for "$query"'));
        return;
      }
      
      emit(PlaceSearchSuccess(places: places));
    } catch (e) {
      String errorMessage = 'Search failed';
      
      if (e.toString().contains('401')) {
        errorMessage = 'Invalid Mapbox token';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Check your internet connection';
      }
      
      emit(PlaceSearchError(errorMessage));
    }
  }

  void selectPlace(MapboxPlace place) {
    _selectedPlace = place;
    emit(PlaceSelected(place)); // هذا الـ state مستقل ومش هيتأثر بالـ timer
  }

  void hideSuggestions() {
    if (state is PlaceSearchSuccess) {
      final currentState = state as PlaceSearchSuccess;
      emit(currentState.copyWith(showSuggestions: false));
    }
  }

  void showSuggestions() {
    if (state is PlaceSearchSuccess) {
      final currentState = state as PlaceSearchSuccess;
      emit(currentState.copyWith(showSuggestions: true));
    }
  }

  void clearSearch() {
    _selectedPlace = null;
    emit(PlaceSearchInitial());
  }

  Future<void> publishTrip(double driverLat, double driverLng) async {
    if (_selectedPlace == null) {
      emit(TripPublishError("No selected place"));
      return;
    }
    
    try {
      emit(TripPublishing(_selectedPlace!));
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(TripPublishError("User not found"));
        return;
      }
      
      await FirebaseFirestore.instance.collection('trips').add({
        'driverId': userId,
        'driverLocation': {
          'lat': driverLat,
          'lng': driverLng,
        },
        'destination': _selectedPlace!.toJson(),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'passengers': [],
        'maxPassengers': 4,
        'availableSeats': 4,
      });
      
      emit(TripPublished(
        place: _selectedPlace!,
        message: 'Your Trip is Published to ${_selectedPlace!.name}',
      ));
      
      // مسح المكان المختار بعد النشر
      _selectedPlace = null;
    } catch (e) {
      emit(TripPublishError(e.toString()));
    }
  }
}