import 'dart:async';

import 'package:carpooling_app/business_logic/cubits/PlaceSearchCubit/place_search_cubit.dart';
import 'package:carpooling_app/business_logic/cubits/PlaceSearchCubit/place_search_states.dart';
import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class Homeapp extends StatefulWidget {
  const Homeapp({super.key});

  @override
  State<Homeapp> createState() => _HomeappState();
}

class _HomeappState extends State<Homeapp> with WidgetsBindingObserver {
  MapboxMap? _mapboxMap;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  late Usersetupcubit userSetupCubit;
  double? lat;
  double? lng;
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool showSuggestions = false;
  bool _isSelectingPlace = false; // فلاج لمنع البحث أثناء اختيار مكان

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userSetupCubit = context.read<Usersetupcubit>();
    userSetupCubit.stratTracking();

    _searchController.addListener(() {
      // تجاهل التغيير لو إحنا بنختار مكان
      if (_isSelectingPlace) {
        return;
      }

      final searchText = _searchController.text.trim();

      // إلغاء البحث السابق
      _searchTimer?.cancel();

      if (searchText.isEmpty) {
        context.read<PlaceSearchCubit>().clearSearch();
        return;
      }

      // تأخير البحث لمدة 500ms
      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && !_isSelectingPlace) {
          context.read<PlaceSearchCubit>().searchPlaces(searchText);
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
    WidgetsBinding.instance.removeObserver(this);
    _searchTimer?.cancel(); // إضافة هذا السطر المهم!
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        userSetupCubit.stopTracking();
        break;
      case AppLifecycleState.resumed:
        userSetupCubit.stratTracking();
        break;
      default:
        break;
    }
  }

  void _goToMyLocation() {
    if (_mapboxMap != null && lat != null && lng != null) {
      _mapboxMap!.easeTo(
        CameraOptions(center: Point(coordinates: Position(lng!, lat!))),
        MapAnimationOptions(duration: 800),
      );
    }
  }

  Future<void> _onMapCreated(controller) async {
    _mapboxMap = controller;

    await _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    _goToMyLocation();
  }

  void onPlaceSelected(MapboxPlace place) {
    _isSelectingPlace = true; // منع البحث
    _searchController.text = place.name;
    _searchFocus.unfocus();
    context.read<PlaceSearchCubit>().selectPlace(place);
    
    // انتظار شوية عشان الـ TextField ميبحثش تاني
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isSelectingPlace = false;
      }
    });
  }

  void onClearSearch() {
    _isSelectingPlace = true; // منع البحث أثناء المسح
    _searchController.clear();
    _searchFocus.unfocus();
    context.read<PlaceSearchCubit>().clearSearch();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isSelectingPlace = false;
      }
    });
  }

  void onPublishTrip() {
    if (lat != null && lng != null) {
      context.read<PlaceSearchCubit>().publishTrip(lat!, lng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          lat = userData["location"]["lat"];
          lng = userData["location"]["lng"];

          return BlocListener<PlaceSearchCubit, PlaceSearchState>(
            listenWhen: (previous, current) {
              return current != previous;
            },
            listener: (context, state) {
              if (state is TripPublished) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
                _searchController.clear();
              } else if (state is TripPublishError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.erorrMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is PlaceSearchError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.erorrMessage),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Stack(
              children: [
                MapWidget(
                  styleUri: MapboxStyles.DARK,
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
                        _buildSearchField(),

                        BlocBuilder<PlaceSearchCubit, PlaceSearchState>(
                          builder: (context, state) {
                            // إضافة debug prints لفهم المشكلة
                            print("Current state: ${state.runtimeType}");
                            
                            if (state is PlaceSearchSuccess) {
                              print("Places count: ${state.places.length}");
                              print("Show suggestions: ${state.showSuggestions}");
                              return _buildSuggestionsList(state.places);
                            } else if (state is PlaceSelected) {
                              print("Place selected: ${state.selectedPlace.name}");
                              return _buildSelectedPlace(state.selectedPlace);
                            } else if (state is PlaceSearchLoading) {
                              print("Loading...");
                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    CircularProgressIndicator(strokeWidth: 2),
                                    SizedBox(width: 16),
                                    Text("Searching..."),
                                  ],
                                ),
                              );
                            } else if (state is PlaceSearchError) {
                              print("Error: ${state.erorrMessage}");
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
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildSuggestionsList(List<MapboxPlace> places) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 12, spreadRadius: 0, color: Colors.black12),
        ],
      ),
      constraints: BoxConstraints(maxHeight: 260.h),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            leading: const Icon(Icons.place_outlined, color: Colors.red),
            title: Text(
              place.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              place.fullAddress,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onPlaceSelected(place),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: places.length,
      ),
    );
  }

  Widget _buildSearchField() {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50.h, // زودت الارتفاع شوية
        decoration: BoxDecoration(
          color: Colors.white, // غيرت اللون من grey لـ white
          borderRadius: BorderRadius.circular(8),
        ),
        child: BlocBuilder<PlaceSearchCubit, PlaceSearchState>(
          builder: (context, state) {
            return TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Where are you going? ",
                hintStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state is PlaceSearchLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onTapUpOutside: (_) {
                _searchFocus.unfocus();
              },
              onSubmitted: (_) {
                context.read<PlaceSearchCubit>().hideSuggestions();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedPlace(MapboxPlace place) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 8, spreadRadius: 0, color: Colors.black12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.fullAddress,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<PlaceSearchCubit, PlaceSearchState>(
              builder: (context, state) {
                final isPublishing = state is TripPublishing;
                return ElevatedButton.icon(
                  onPressed: isPublishing ? null : onPublishTrip,
                  icon: isPublishing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.publish),
                  label: Text(isPublishing ? 'جاري النشر...' : 'نشر رحلة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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