import 'dart:async';
import 'package:carpooling_app/business_logic/cubits/DriverPlacesSearchCubit/driver_places_search_cubit.dart';
import 'package:carpooling_app/business_logic/cubits/DriverPlacesSearchCubit/driver_places_search_states.dart';
import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementCubit.dart';
import 'package:carpooling_app/business_logic/cubits/MapDisplayCubit/MapDisplayCubit.dart';
import 'package:carpooling_app/business_logic/cubits/MapDisplayCubit/MapDisplayStates.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/data/models/TripVisualizationData.dart';
import 'package:carpooling_app/data/models/UserLocationData.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomeappDriver extends StatefulWidget {
  const HomeappDriver({super.key});

  @override
  State<HomeappDriver> createState() => _HomeappDriverState();
}

class _HomeappDriverState extends State<HomeappDriver> with WidgetsBindingObserver {
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

    _searchController.addListener(() {
      if (_isSelectingPlace) {
        return;
      }

      final searchText = _searchController.text.trim();
      _searchTimer?.cancel();

      if (searchText.isEmpty) {
        context.read<DriverPlacesSearchCubit>().clearSearch();
        setState(() {
          showSuggestions = false;
        });
        return;
      }

      setState(() {
        showSuggestions = true;
      });

      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && !_isSelectingPlace && lat != null && lng != null) {
          final proximity = '${lng ?? ''},${lat ?? ''}';
          context.read<DriverPlacesSearchCubit>().searchPlaces(searchText, proximity: proximity);
        }
      });
    });

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() {
          showSuggestions = false;
        });
      } else {
        final searchText = _searchController.text.trim().toLowerCase();
        setState(() {
          showSuggestions = searchText.isNotEmpty;
        });
      }
    });
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
      _pointAnnotationManager = await _mapboxMap!.annotations.createPointAnnotationManager();
      _polylineAnnotationManager = await _mapboxMap!.annotations.createPolylineAnnotationManager();

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

  // Update user location in Firestore and MapDisplayCubit
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
    if (_pointAnnotationManager == null) return;

    try {
      // Clear existing user markers
      for (var marker in _userMarkers.values) {
        await _pointAnnotationManager!.delete(marker);
      }
      _userMarkers.clear();

      // Add new markers for online users (excluding current user)
      for (var user in users) {
        if (user.userId != uid && user.status == 'online') {
          final annotation = await _pointAnnotationManager!.create(
            PointAnnotationOptions(
              geometry: Point(coordinates: Position(user.lng, user.lat)),
              textField: user.name,
              textSize: 12.0,
              textColor: user.type == 'driver' ? 0xFF2196F3 : 0xFF4CAF50,
              iconImage: user.type == 'driver' ? 'car-icon' : 'person-icon',
              iconSize: 0.8,
            ),
          );
          _userMarkers[user.userId] = annotation;
        }
      }
    } catch (e) {
      print('Error adding user markers: $e');
    }
  }

Future<void> _addTripMarkers(List<TripVisualizationData> trips) async {
  if (_pointAnnotationManager == null || _polylineAnnotationManager == null) return;

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

    // معالجة كل رحلة
    for (var trip in trips) {
      // فقط ارسم الخطوط والماركرز للرحلات اللي ليها ركاب مقبولين
      if (trip.acceptedPassengers.isNotEmpty) {
        
        // Add destination marker
        final destinationMarker = await _pointAnnotationManager!.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(trip.destinationLng, trip.destinationLat)),
            textField: trip.destinationName,
            textSize: 10.0,
            textColor: 0xFFFF5722,
            iconImage: 'destination-icon',
            iconSize: 0.6,
          ),
        );
        _tripMarkers['${trip.tripId}_dest'] = destinationMarker;

        // رسم خط من السائق للوجهة - فقط لو في ركاب مقبولين
        final routeLine = await _polylineAnnotationManager!.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: [
              Position(trip.driverLng, trip.driverLat),
              Position(trip.destinationLng, trip.destinationLat),
            ]),
            lineColor: 0xFF2196F3,
            lineWidth: 3.0,
            lineOpacity: 0.7,
          ),
        );
        _routeLines['${trip.tripId}_main'] = routeLine;

        // رسم ماركرز وخطوط للركاب المقبولين فقط
        for (var passenger in trip.acceptedPassengers) {
          // Add passenger marker
          final passengerMarker = await _pointAnnotationManager!.create(
            PointAnnotationOptions(
              geometry: Point(coordinates: Position(passenger.lng, passenger.lat)),
              textField: passenger.passengerName,
              textSize: 10.0,
              textColor: 0xFF4CAF50,
              iconImage: 'passenger-icon',
              iconSize: 0.5,
            ),
          );
          _tripMarkers['${trip.tripId}_passenger_${passenger.passengerId}'] = passengerMarker;

          // draw green line from driver to rider 
          final passengerToDriverLine = await _polylineAnnotationManager!.create(
            PolylineAnnotationOptions(
              geometry: LineString(coordinates: [
                Position(passenger.lng, passenger.lat),
                Position(trip.driverLng, trip.driverLat),
              ]),
              lineColor: 0xFF4CAF50,
              lineWidth: 2.0,
              lineOpacity: 0.6,
             // lineDasharray: [3.0, 3.0], 
            ),
          );
          _routeLines['${trip.tripId}_passenger_${passenger.passengerId}'] = passengerToDriverLine;
        }
      }
     
    }
  } catch (e) {
    print('Error adding trip markers: $e');
  }
}
 
 
  void onPlaceSelected(MapboxPlace place) {
    _isSelectingPlace = true;
    _searchController.text = place.name;
    _searchFocus.unfocus();
    context.read<DriverPlacesSearchCubit>().selectPlace(place);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isSelectingPlace = false;
      }
    });
  }

  void onClearSearch() {
    _isSelectingPlace = true;
    _searchController.clear();
    _searchFocus.unfocus();
    context.read<DriverPlacesSearchCubit>().clearSearch();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isSelectingPlace = false;
        setState(() => showSuggestions = false);
      }
    });
  }

  void onPublishTrip() {
    if (lat != null && lng != null) {
      context.read<DriverPlacesSearchCubit>().publishTrip(lat!, lng!);
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
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            double newLat = userData["location"]["lat"];
            double newLng = userData["location"]["lng"];
            
            // Update location if it changed
            if (lat != newLat || lng != newLng) {
              lat = newLat;
              lng = newLng;
              _updateLocationInFirestore(lat!, lng!);
            }
      
            return MultiBlocListener(
              listeners: [
                BlocListener<DriverPlacesSearchCubit, DriverPlacesSearchStates>(
                  listener: (context, state) {
                    if (state is DriverTripPublished) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      _searchController.clear();
                        context.read<DriverTripManagementCubit>().getAllDriverTrips();
                    } else if (state is DriverTripPublishError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.erorrMessage),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
                BlocListener<MapDisplayCubit, MapDisplayStates>(
                  listener: (context, state) {
                    if (state is MapDisplayLoaded) {
                      // Update markers when map data changes
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
                    styleUri: isDarkMode ? MapboxStyles.DARK : MapboxStyles.LIGHT,
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
      
                          BlocBuilder<DriverPlacesSearchCubit, DriverPlacesSearchStates>(
                            builder: (context, state) {
                              if (state is DriverPlacesSearchSuccess && showSuggestions) {
                                return _buildSuggestionsList(state.places, isDarkMode);
                              } else if (state is PlaceSelected) {
                                return _buildSelectedPlace(state.selectedPlace, isDarkMode);
                              } else if (state is DriverPlacesSearchLoading) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 12, 
                                        spreadRadius: 0, 
                                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        "Searching...",
                                        style: TextStyle(
                                          color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // Display current user's trips info
                          BlocBuilder<MapDisplayCubit, MapDisplayStates>(
                            builder: (context, state) {
                              if (state is MapDisplayLoaded) {
                                var currentUserTrips = context.read<MapDisplayCubit>().getCurrentUserTrips();
                                if (currentUserTrips.isNotEmpty) {
                                  return _buildCurrentTripInfo(currentUserTrips.first, isDarkMode);
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
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
          foregroundColor: Colors.white,
          child: const Icon(Icons.my_location),
        ),
      ),
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
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'To: ${trip.destinationName}',
            style: TextStyle(
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          if (trip.acceptedPassengers.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Passengers (${trip.acceptedPassengers.length}):',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            ...trip.acceptedPassengers.map((passenger) => 
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 4.h),
                child: Text(
                  '• ${passenger.passengerName}',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(List<MapboxPlace> places, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 12, 
            spreadRadius: 0, 
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
          ),
        ],
      ),
      constraints: BoxConstraints(maxHeight: 260.h),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            leading: Icon(Icons.place_outlined, color: AppColors.error),
            title: Text(
              place.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              place.fullAddress,
              style: TextStyle(
                fontSize: 12, 
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onPlaceSelected(place),
          );
        },
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isDarkMode ? AppColors.darkBorder : AppColors.border,
        ),
        itemCount: places.length,
      ),
    );
  }

  Widget _buildSearchField(bool isDarkMode) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50.h, 
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: BlocBuilder<DriverPlacesSearchCubit, DriverPlacesSearchStates>(
          builder: (context, state) {
            return TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: "Where are you going? ",
                hintStyle: TextStyle(
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.darkBorder : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state is DriverPlacesSearchLoading)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: onClearSearch,
                        icon: Icon(
                          Icons.clear,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              onTapUpOutside: (_) {
                _searchFocus.unfocus();
              },
              onSubmitted: (_) {
                context.read<DriverPlacesSearchCubit>().hideSuggestions();
                setState(() => showSuggestions = false);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedPlace(MapboxPlace place, bool isDarkMode) {
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
              Icon(Icons.location_on, color: AppColors.error, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      place.fullAddress,
                      style: TextStyle(
                        fontSize: 12.sp, 
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<DriverPlacesSearchCubit, DriverPlacesSearchStates>(
              builder: (context, state) {
                final isPublishing = state is DriverTripPublishing;
                return ElevatedButton.icon(
                  onPressed: isPublishing ? null : onPublishTrip,
                  icon: isPublishing
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.publish, size: 20.sp),
                  label: Text(isPublishing ? 'Publishing...' : 'Publish Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}