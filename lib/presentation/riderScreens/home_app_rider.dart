import 'dart:async';
import 'package:carpooling_app/business_logic/cubits/MapDisplayCubit/MapDisplayCubit.dart';
import 'package:carpooling_app/business_logic/cubits/MapDisplayCubit/MapDisplayStates.dart';
import 'package:carpooling_app/business_logic/cubits/requestToJoinTripCubit/requestToJoinTripCubit.dart';
import 'package:carpooling_app/business_logic/cubits/requestToJoinTripCubit/requestToJoinTripStetes.dart';
import 'package:carpooling_app/business_logic/cubits/riderJoinRequests.dart/riderJoinRequestsCubit.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/data/models/TripVisualizationData.dart';
import 'package:carpooling_app/data/models/UserLocationData.dart';
import 'package:carpooling_app/data/models/trip_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomeAppRider extends StatefulWidget {
  const HomeAppRider({super.key});

  @override
  State<HomeAppRider> createState() => _HomeAppRiderState();
}

class _HomeAppRiderState extends State<HomeAppRider>
    with WidgetsBindingObserver {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  double? lat;
  double? lng;
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool showSuggestions = false;
  bool _isSelectingPlace = false;

  Timer? _searchTimer;

  // Map markers management
  final Map<String, PointAnnotation> _userMarkers = {};
  final Map<String, PointAnnotation> _tripMarkers = {};
  final Map<String, PolylineAnnotation> _routeLines = {};

  @override
  void initState() {
    super.initState();

    // Start listening to map data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapDisplayCubit>().startListeningToMapData();
      context.read<MapDisplayCubit>().setUserStatus('online');
    });

    _searchController.addListener(_handleSearchInput);
    _searchFocus.addListener(_handleFocusChange);
  }

  void _handleSearchInput() {
    if (_isSelectingPlace) return;

    final searchText = _searchController.text.trim();
    _searchTimer?.cancel();

    if (searchText.isEmpty) {
      context.read<Requesttojointripcubit>().clearSearch();
      setState(() => showSuggestions = false);
      return;
    }

    setState(() => showSuggestions = true);

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isSelectingPlace && lat != null && lng != null) {
        context.read<Requesttojointripcubit>().serachPlaces(
          searchText,
          proximity: '$lng,$lat',
        );
      }
    });
  }

  void _handleFocusChange() {
    if (!_searchFocus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_isSelectingPlace) {
          setState(() => showSuggestions = false);
          context.read<Requesttojointripcubit>().hideSuggestions();
        }
      });
    } else {
      final searchText = _searchController.text.trim();
      if (searchText.isNotEmpty) {
        setState(() => showSuggestions = true);
        context.read<Requesttojointripcubit>().showSuggestions();
      }
    }
  }

  @override
  void dispose() {
    context.read<MapDisplayCubit>().setUserStatus('offline');
    _searchTimer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _clearAllAnnotations();

    super.dispose();
  }

  void _goToMyLocation() {
    if (_mapboxMap != null && lat != null && lng != null) {
      _mapboxMap!.easeTo(
        CameraOptions(center: Point(coordinates: Position(lng!, lat!))),
        MapAnimationOptions(duration: 800),
      );
    }
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    _mapboxMap = controller;

    try {
      _pointAnnotationManager = await _mapboxMap!.annotations
          .createPointAnnotationManager();
      _polylineAnnotationManager = await _mapboxMap!.annotations
          .createPolylineAnnotationManager();

      await _mapboxMap!.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
        ),
      );

      _goToMyLocation();
    } catch (e) {
      print('Error initializing map: $e');
    }
  }

  void _updateLocationInFirestore(double newLat, double newLng) {
    context.read<MapDisplayCubit>().updateUserLocation(newLat, newLng);
  }

  Future<void> _clearAllAnnotations() async {
    try {
      if (_pointAnnotationManager != null) {
        await _pointAnnotationManager!.deleteAll();
      }
      if (_polylineAnnotationManager != null) {
        await _polylineAnnotationManager!.deleteAll();
      }
      _userMarkers.clear();
      _tripMarkers.clear();
      _routeLines.clear();
    } catch (e) {
      print('Error clearing annotations: $e');
    }
  }

  Future<void> _addUserMarkers(List<UserLocationData> users) async {
    // Don't add any individual user markers
    // Only show markers for people in the same trip through _addTripMarkers
    return;
  }

  Future<void> _addTripMarkers(List<TripVisualizationData> trips) async {
    if (_pointAnnotationManager == null || _polylineAnnotationManager == null)
      return;

    try {
      // Clear existing trip markers and routes
      for (var marker in _tripMarkers.values) {
        await _pointAnnotationManager!.delete(marker);
      }
      for (var route in _routeLines.values) {
        await _polylineAnnotationManager!.delete(route);
      }
      _tripMarkers.clear();
      _routeLines.clear();

      // Only show markers and routes for trips where current user is a passenger
      for (var trip in trips) {
        // Check if current user is in this trip as passenger
        bool isUserInTrip = trip.acceptedPassengers.any(
          (passenger) => passenger.passengerId == uid,
        );

        // Only show route and markers if user is part of this trip
        if (isUserInTrip) {
          // Get driver status from Firestore
          DocumentSnapshot driverDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(trip.driverId)
              .get();

          String driverStatus = 'offline';
          if (driverDoc.exists) {
            final driverData = driverDoc.data() as Map<String, dynamic>;
            driverStatus = driverData['status'] as String? ?? 'offline';
          }

          // Skip trips where driver is offline
          if (driverStatus != 'online') {
            continue;
          }

          // Add destination marker
          final destinationMarker = await _pointAnnotationManager!.create(
            PointAnnotationOptions(
              geometry: Point(
                coordinates: Position(trip.destinationLng, trip.destinationLat),
              ),
              textField: trip.destinationName,
              textSize: 12.0,
              textColor: 0xFFFF5722,
              iconImage: 'destination-icon',
              iconSize: 0.8,
            ),
          );
          _tripMarkers['${trip.tripId}_dest'] = destinationMarker;

          // Add driver marker
          final driverMarker = await _pointAnnotationManager!.create(
            PointAnnotationOptions(
              geometry: Point(
                coordinates: Position(trip.driverLng, trip.driverLat),
              ),
              textField: '${trip.driverName} (Driver)',
              textSize: 12.0,
              textColor: 0xFF2196F3,
              iconImage: 'car-icon',
              iconSize: 1.0,
            ),
          );
          _tripMarkers['${trip.tripId}_driver'] = driverMarker;

          // Add route line from driver to destination
          final driverRouteLine = await _polylineAnnotationManager!.create(
            PolylineAnnotationOptions(
              geometry: LineString(
                coordinates: [
                  Position(trip.driverLng, trip.driverLat),
                  Position(trip.destinationLng, trip.destinationLat),
                ],
              ),
              lineColor: 0xFF2196F3,
              lineWidth: 4.0,
              lineOpacity: 0.8,
            ),
          );
          _routeLines['${trip.tripId}_driver_route'] = driverRouteLine;

          // Add route lines from each passenger to destination
          for (var passenger in trip.acceptedPassengers) {
            // Add passenger to destination line
            final passengerToDestLine = await _polylineAnnotationManager!
                .create(
                  PolylineAnnotationOptions(
                    geometry: LineString(
                      coordinates: [
                        Position(passenger.lng, passenger.lat),
                        Position(trip.destinationLng, trip.destinationLat),
                      ],
                    ),
                    lineColor: passenger.passengerId == uid
                        ? 0xFF4CAF50
                        : 0xFFFF9800,
                    lineWidth: passenger.passengerId == uid ? 3.0 : 2.0,
                    lineOpacity: 0.7,
                  ),
                );
            _routeLines['${trip.tripId}_passenger_${passenger.passengerId}_route'] =
                passengerToDestLine;

            // Add passenger markers
            final passengerMarker = await _pointAnnotationManager!.create(
              PointAnnotationOptions(
                geometry: Point(
                  coordinates: Position(passenger.lng, passenger.lat),
                ),
                textField: passenger.passengerId == uid
                    ? 'You'
                    : passenger.passengerName,
                textSize: passenger.passengerId == uid ? 14.0 : 12.0,
                textColor: passenger.passengerId == uid
                    ? 0xFF4CAF50
                    : 0xFFFF9800,
                iconImage: passenger.passengerId == uid
                    ? 'my-location-icon'
                    : 'passenger-icon',
                iconSize: passenger.passengerId == uid ? 0.8 : 0.6,
              ),
            );
            _tripMarkers['${trip.tripId}_passenger_${passenger.passengerId}'] =
                passengerMarker;
          }
        }
        // Remove the else block that was showing available drivers
        // Now only trips where user is a passenger will show on map
      }
    } catch (e) {
      print('Error adding trip markers: $e');
    }
  }

  void onClearSearch() {
    _isSelectingPlace = true;
    _searchController.clear();
    _searchFocus.unfocus();
    context.read<Requesttojointripcubit>().clearSearch();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isSelectingPlace = false;
        setState(() => showSuggestions = false);
      }
    });
  }

  void _onPlaceSelected(place) {
    if (lat != null && lng != null) {
      _isSelectingPlace = true;
      setState(() => showSuggestions = false);

      _searchController.text = place.name;
      _searchFocus.unfocus();
      context.read<Requesttojointripcubit>().selectPlace(place, lat!, lng!);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _isSelectingPlace = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final newLat = userData["location"]["lat"];
            final newLng = userData["location"]["lng"];

            if (lat != newLat || lng != newLng) {
              lat = newLat;
              lng = newLng;
              _updateLocationInFirestore(lat!, lng!);
            }

            return MultiBlocListener(
              listeners: [
                BlocListener<Requesttojointripcubit, RiderTripSearchStates>(
                  listener: (context, state) {
                    if (state is TripsSearchError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
                BlocListener<MapDisplayCubit, MapDisplayStates>(
                  listener: (context, state) {
                    if (state is MapDisplayLoaded) {
                      _addUserMarkers(state.userLocations);
                      _addTripMarkers(state.activeTrips);
                    } else if (state is MapDisplayError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Map error: ${state.errorMessage}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              ],
              child: Stack(
                children: [
                  MapWidget(
                    styleUri: isDarkMode
                        ? MapboxStyles.DARK
                        : MapboxStyles.LIGHT,
                    cameraOptions: CameraOptions(
                      center: Point(coordinates: Position(lng!, lat!)),
                      zoom: 17,
                    ),
                    onMapCreated: _onMapCreated,
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        right: 20,
                        left: 20,
                      ),
                      child: Column(
                        children: [
                          _buildSearchField(isDarkMode),
                          _buildSearchResults(context, isDarkMode),
                          _buildCurrentTripInfoSection(context, isDarkMode),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _goToMyLocation,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.my_location, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isDarkMode) {
    return BlocBuilder<Requesttojointripcubit, RiderTripSearchStates>(
      builder: (context, state) {
        return Column(
          children: [
            if (showSuggestions && state is RiderPlacesSearchSuccess)
              _buildPlaceSuggestions(state.places, isDarkMode),
            if (state is TripsSearchLoading) _buildLoadingTrips(isDarkMode),
            if (state is TripsSearchSuccess)
              _buildTripResults(context, isDarkMode),
            if (state is NoTripsFound)
              _buildNoTripsFound(state.destination.name, isDarkMode),
            if (state is PlaceSelected)
              _buildPlaceSelectedCard(state.selectedPlace.name, isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildCurrentTripInfoSection(BuildContext context, bool isDarkMode) {
    return BlocBuilder<MapDisplayCubit, MapDisplayStates>(
      builder: (context, state) {
        if (state is MapDisplayLoaded) {
          final passengerTrips = context
              .read<MapDisplayCubit>()
              .getTripsAsPassenger();
          if (passengerTrips.isNotEmpty) {
            return _buildCurrentTripInfo(passengerTrips.first, isDarkMode);
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCurrentTripInfo(TripVisualizationData trip, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.drive_eta, color: AppColors.success),
              SizedBox(width: 8.w),
              Text(
                'Your Active Trip',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Driver: ${trip.driverName}',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'To: ${trip.destinationName}',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDarkMode) {
    return BlocBuilder<Requesttojointripcubit, RiderTripSearchStates>(
      builder: (context, state) {
        final isLoading = state is RiderPlacesSearchLoading;

        return Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: "Where do you want to go?",
                hintStyle: TextStyle(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.darkBorder : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? AppColors.darkSurface
                    : AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    if (_searchController.text.isNotEmpty && !isLoading)
                      IconButton(
                        onPressed: onClearSearch,
                        icon: Icon(
                          Icons.clear,
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              onTapOutside: (_) => _searchFocus.unfocus(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceSuggestions(List places, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: places.length > 5 ? 5 : places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            leading: Icon(Icons.location_on, color: AppColors.primary),
            title: Text(
              place.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              place.fullAddress,
              style: TextStyle(
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _onPlaceSelected(place),
          );
        },
      ),
    );
  }

  Widget _buildLoadingTrips(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching for available trips...',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripResults(BuildContext context, bool isDarkMode) {
    final searchState = context.read<Requesttojointripcubit>().state;

    if (searchState is TripsSearchSuccess) {
      final availableTrips = searchState.availableTrips;

      return Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              spreadRadius: 0,
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Available Trips (${availableTrips.length})',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 300.h,
              child: ListView.builder(
                itemCount: availableTrips.length,
                itemBuilder: (context, index) {
                  final trip = availableTrips[index];
                  return _buildTripCard(trip, isDarkMode);
                },
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTripCard(TripModel trip, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? AppColors.darkBackground : AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     // 'Driver: ${trip.driverId}',
                     'Driver: Hamed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'To: ${trip.destination.name}',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${trip.passengers.length} passengers',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _requestToJoinTrip(trip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Request to Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoTripsFound(String destination, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No trips found to',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            destination,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different location or check back later',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceSelectedCard(String placeName, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Searching trips to: $placeName',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestToJoinTrip(TripModel trip) {
    final cubit = context.read<Requesttojointripcubit>();
    final cubit2= context.read<RiderJoinRequestsCubit>();
    String riderId = FirebaseAuth.instance.currentUser!.uid;
    showDialog(
      context: context,
      builder: (context) {
        return BlocConsumer<Requesttojointripcubit, RiderTripSearchStates>(
          bloc: cubit,
          listener: (context, state) {
            if (state is JoinRequestSuccess) {
              Navigator.pop(context);
               cubit2.getRiderJoinRequests(riderId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip request sent successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is JoinRequestError) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AlreadyRequestedJoin) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.warning,
                ),
              );
            } else if (state is TripFull) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          },
          builder: (context, state) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: isDarkMode
                  ? AppColors.darkSurface
                  : AppColors.surface,
              title: Text(
                'Request to Join Trip',
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state is JoinRequestLoading)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Sending request...',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Do you want to request to join this trip to ${trip.destination.name}?',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              actions: [
                if (state is! JoinRequestLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),

                if (state is! JoinRequestLoading)
                  ElevatedButton(
                    onPressed: (){
                 cubit.sendRquestToJoinTrip(trip.id!);
                
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Send Request"),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
