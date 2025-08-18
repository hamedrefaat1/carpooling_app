import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomeAppRider extends StatefulWidget {
  const HomeAppRider({super.key});

  @override
  State<HomeAppRider> createState() => _HomeAppRiderState();
}

class _HomeAppRiderState extends State<HomeAppRider> with WidgetsBindingObserver {
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
      // تجاهل التغيير لو إحنا بنختار مكان
      if (_isSelectingPlace) {
        return;
      }

      final searchText = _searchController.text.trim();

      // إلغاء البحث السابق
      _searchTimer?.cancel();

      if (searchText.isEmpty) {
        // TODO: clear trip search results
        return;
      }

      // تأخير البحث لمدة 500ms
      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && !_isSelectingPlace) {
          // TODO: search for trips to this destination
          print('Searching for trips to: $searchText');
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
    // TODO: clear trip search results
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isSelectingPlace = false;
      }
    });
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
              // الخريطة
              MapWidget(
                styleUri: MapboxStyles.DARK,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(lng!, lat!)),
                  zoom: 17,
                ),
                onMapCreated: _onMapCreated,
              ),

              // UI Elements فوق الخريطة
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
                      
                      // TODO: هنا هنحط نتائج البحث عن الرحلات
                      // _buildTripResults(),
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
            hintText: "Where do you want to go?", // مختلف عن السائق
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: إضافة loading indicator للبحث عن الرحلات
                if (_searchController.text.isNotEmpty)
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
            prefixIcon: Icon(
              Icons.search,
              color: Colors.blue, // أزرق للراكب بدل من رمادي
              size: 20,
            ),
          ),
          onTapUpOutside: (_) {
            _searchFocus.unfocus();
          },
          onSubmitted: (_) {
            // TODO: trigger search for trips
            print('Search submitted for: ${_searchController.text}');
          },
          onChanged: (value){
            if (value.isNotEmpty){
              setState(() {
                
              });
            }
          },
        ),
      ),
    );
  }


  // TODO: دالة لعرض نتائج البحث عن الرحلات
  Widget _buildTripResults() {
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
            child: Text(
              'Available Trips',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // TODO: ListView للرحلات المتاحة
          Container(
            height: 200.h,
            child: Center(
              child: Text(
                'Search for trips will appear here',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}