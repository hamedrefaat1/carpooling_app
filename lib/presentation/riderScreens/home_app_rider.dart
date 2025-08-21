import 'dart:async';
import 'package:carpooling_app/business_logic/cubits/requestToJoinTripCubit/requestToJoinTripCubit.dart';
import 'package:carpooling_app/business_logic/cubits/requestToJoinTripCubit/requestToJoinTripStetes.dart';
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
  String uid = FirebaseAuth.instance.currentUser!.uid;
  double? lat;
  double? lng;
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool showSuggestions = false;
  bool _isSelectingPlace = false;

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_isSelectingPlace) {
        return;
      }

      final searchText = _searchController.text.trim();

      // إلغاء البحث السابق
      _searchTimer?.cancel();

      if (searchText.isEmpty) {
        context.read<Requesttojointripcubit>().clearSearch();
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
          context.read<Requesttojointripcubit>().serachPlaces(
            searchText,
            proximity: '$lng,$lat',
          );
        }
      });
    });

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        // تأخير إخفاء النتائج للسماح بالضغط عليها
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_isSelectingPlace) {
            setState(() {
              showSuggestions = false;
            });
            context.read<Requesttojointripcubit>().hideSuggestions();
          }
        });
      } else {
        final searchText = _searchController.text.trim();
        if (searchText.isNotEmpty) {
          setState(() {
            showSuggestions = true;
          });
          context.read<Requesttojointripcubit>().showSuggestions();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
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

  void onClearSearch() {
    _isSelectingPlace = true;
    _searchController.clear();
    _searchFocus.unfocus();
    context.read<Requesttojointripcubit>().clearSearch();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isSelectingPlace = false;
        setState(() {
          showSuggestions = false;
        });
      }
    });
  }

  void _onPlaceSelected(place) {
    if (lat != null && lng != null) {
      print('Place selected: ${place.name}');

      _isSelectingPlace = true;

      setState(() {
        showSuggestions = false;
      });

      _searchController.text = place.name;
      _searchFocus.unfocus();

      // to search a vilaible trips
      context.read<Requesttojointripcubit>().selectPlace(place, lat!, lng!);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _isSelectingPlace = false;
        }
      });
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

          return Stack(
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
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Column(
                    children: [
                      _buildSearchField(),

                      BlocConsumer<
                        Requesttojointripcubit,
                        RiderTripSearchStates
                      >(
                        listener: (context, state) {
                          if (state is TripsSearchError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          print('Current State: ${state.runtimeType}');
                          if (state is RiderPlacesSearchSuccess) {
                            print('Places found: ${state.places.length}');
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            children: [
                              if (showSuggestions &&
                                  state is RiderPlacesSearchSuccess)
                                _buildPlaceSuggestions(state.places),

                              if (state is TripsSearchLoading)
                                _buildLoadingTrips(),

                              if (state is TripsSearchSuccess)
                                _buildTripResults(state.availableTrips),

                              if (state is NoTripsFound)
                                _buildNoTripsFound(state.destination.name),

                              if (state is PlaceSelected)
                                _buildPlaceSelectedCard(
                                  state.selectedPlace.name,
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchField() {
    return BlocBuilder<Requesttojointripcubit, RiderTripSearchStates>(
      builder: (context, state) {
        bool isLoading = state is RiderPlacesSearchLoading;

        return Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: "Where do you want to go?",
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
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
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (_searchController.text.isNotEmpty && !isLoading)
                      IconButton(
                        onPressed: onClearSearch,
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                  ],
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              onTapOutside: (_) {
                _searchFocus.unfocus();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceSuggestions(List places) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(blurRadius: 8, spreadRadius: 0, color: Colors.black12),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: places.length > 5 ? 5 : places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: Text(
              place.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              place.fullAddress,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _onPlaceSelected(place),
          );
        },
      ),
    );
  }

  Widget _buildLoadingTrips() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 8, spreadRadius: 0, color: Colors.black12),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Searching for available trips...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTripResults(List<TripModel> trips) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Available Trips (${trips.length})',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300.h,
            child: ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _buildTripCard(trip);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver: ${trip.driverId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'To: ${trip.destination.name}',
                      style: TextStyle(color: Colors.grey[600]),
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
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${trip.availableSeats} seats',
                      style: TextStyle(
                        color: Colors.green[800],
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
                  onPressed: () {
                   // send request to join trip 
                    _requestToJoinTrip(trip);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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

  Widget _buildNoTripsFound(String destination) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 8, spreadRadius: 0, color: Colors.black12),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No trips found to',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
          Text(
            destination,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different location or check back later',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceSelectedCard(String placeName) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Searching trips to: $placeName',
              style: TextStyle(
                color: Colors.blue[800],
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
    showDialog(

      context: context,
      builder: (context) {
        return BlocConsumer<Requesttojointripcubit, RiderTripSearchStates>(
          bloc: cubit,
          listener: (context, state) {
            if (state is JoinRequestSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip request sent successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is JoinRequestError) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AlreadyRequestedJoin) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is TripFull) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Request to Join Trip'),
              content: Column(
         mainAxisSize: MainAxisSize.min,
                children: [
                  if(state is JoinRequestLoading)
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.h,),
                        Text('Sending request...'),
                      ],
                    )
                  else 
                   Text(
                  'Do you want to request to join this trip to ${trip.destination.name}?',
                ),
        
                ],
                
              ),
             actions: [
              if(state is JoinRequestLoading == false)
                TextButton(
                  onPressed:()=> Navigator.pop(context), 
                  child: Text("Cancle")),
        
              
               ElevatedButton(
                onPressed: (){
                  cubit.sendRquestToJoinTrip(trip.id!);
                },
               style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white
               ),
                 child: Text("Send Request")
                 )    
             ],
            );
          },
        );
      },
    );
  }
}
