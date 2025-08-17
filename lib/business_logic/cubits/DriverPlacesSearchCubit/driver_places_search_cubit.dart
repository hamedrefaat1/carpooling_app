import 'dart:async';
import 'package:carpooling_app/business_logic/cubits/DriverPlacesSearchCubit/driver_places_search_states.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:carpooling_app/data/repositories/mapbox_srearchPlacesRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverPlacesSearchCubit extends Cubit<DriverPlacesSearchStates> {
  final MapboxSrearchplacesrepo _mapboxSrearchplacesrepo = MapboxSrearchplacesrepo();
  MapboxPlace? _selectedPlace;

  DriverPlacesSearchCubit() : super(DriverPlacesSearchInitial());

  Future<void> searchPlaces(String query, {String? proximity}) async {
    if (query.isEmpty) {
      emit(DriverPlacesSearchInitial());
      return;
    }
    if (query.length < 3) {
      return;
    }

    emit(DriverPlacesSearchLoading());
    try {
      final places = await _mapboxSrearchplacesrepo.getSerachPlaces(
        query,
        proximity: proximity,
      );
      
      if (places.isEmpty) {
        emit(DriverPlacesSearchError('No places found for "$query"'));
        return;
      }
      
      emit(DriverPlacesSearchSuccess(places: places));
    } catch (e) {
      String errorMessage = 'Search failed';
      
      if (e.toString().contains('401')) {
        errorMessage = 'Invalid Mapbox token';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Check your internet connection';
      }
      
      emit(DriverPlacesSearchError(errorMessage));
    }
  }

  void selectPlace(MapboxPlace place) {
    _selectedPlace = place;
    emit(PlaceSelected(place));
  }

  void hideSuggestions() {
    if (state is DriverPlacesSearchSuccess) {
      final currentState = state as DriverPlacesSearchSuccess;
      emit(currentState.copyWith(showSuggestions: false));
    }
  }

  void showSuggestions() {
    if (state is DriverPlacesSearchSuccess) {
      final currentState = state as DriverPlacesSearchSuccess;
      emit(currentState.copyWith(showSuggestions: true));
    }
  }

  void clearSearch() {
    _selectedPlace = null;
    emit(DriverPlacesSearchInitial());
  }

  Future<void> publishTrip(double driverLat, double driverLng) async {
    if (_selectedPlace == null) {
      emit(DriverTripPublishError("No selected place"));
      return;
    }
    
    try {
      emit(DriverTripPublishing(_selectedPlace!));
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(DriverTripPublishError("User not found"));
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
      
      emit(DriverTripPublished(
        place: _selectedPlace!,
        message: 'Your Trip is Published to ${_selectedPlace!.name}',
      ));
      
      _selectedPlace = null;
    } catch (e) {
      emit(DriverTripPublishError(e.toString()));
    }
  }
}