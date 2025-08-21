// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart' as geo;

// class Homeapp extends StatefulWidget {
//   const Homeapp({super.key});

//   @override
//   State<Homeapp> createState() => _HomeappState();
// }

// class _HomeappState extends State<Homeapp> {
//   MapboxMap? _mapboxMap;
//   geo.Position? _currentPosition;
//   StreamSubscription<geo.Position>? _posSub;

//   @override
//   void initState() {

//     super.initState();
//     _initLocationFlow();
//   }

//   Future<void> _initLocationFlow() async {
//     // 1) تأكد إن الخدمة شغالة واطلب صلاحيات
//     if (!await geo.Geolocator.isLocationServiceEnabled()) {
//       // تقدر تفتح إعدادات الموقع للمستخدم لو حبيت
//       return;
//     }
//     var permission = await geo.Geolocator.checkPermission();
//     if (permission == geo.LocationPermission.denied) {
//       permission = await geo.Geolocator.requestPermission();
//     }
//     if (permission == geo.LocationPermission.denied ||
//         permission == geo.LocationPermission.deniedForever) {
//       return;
//     }

//     // 2) هات اللوكيشن الأولي
//     final first = await geo.Geolocator.getCurrentPosition(
//       desiredAccuracy: geo.LocationAccuracy.high,
//     );
//     setState(() => _currentPosition = first);

//     // 3) ستريم تحديثات لايف
//     _posSub = geo.Geolocator.getPositionStream(
//       locationSettings: const geo.LocationSettings(
//         accuracy: geo.LocationAccuracy.high,
//         distanceFilter: 5,
//       ),
//     ).listen((p) {
//       setState(() => _currentPosition = p);
//       if (_mapboxMap != null) {
//         _mapboxMap!.flyTo(
//           CameraOptions(
//             center: Point(coordinates: Position(p.longitude, p.latitude)),
//             zoom: 15,
//           ),
//           MapAnimationOptions(duration: 500),
//         );
//       }
//     });
//   }

//   Future<void> _onMapCreated(MapboxMap controller) async {
//     _mapboxMap = controller;

//     // فعّل الـ User Location Puck (نقطة موقع المستخدم مع نبض)
//     await _mapboxMap!.location.updateSettings(
//       LocationComponentSettings(
//         enabled: true,
//         pulsingEnabled: true,
//         showAccuracyRing: true,
//       ),
//     );

//     // وجّه الكاميرا على اللوكيشن الحالي لو موجود
//     if (_currentPosition != null) {
//       _mapboxMap!.setCamera(
//         CameraOptions(
//           center: Point(
//             coordinates: Position(
//               _currentPosition!.longitude,
//               _currentPosition!.latitude,
//             ),
//           ),
//           zoom: 15,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasPos = _currentPosition != null;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Map (Mapbox)'),
//       ),
//       body: hasPos
//           ? MapWidget(

//               styleUri: MapboxStyles.MAPBOX_STREETS,
//               cameraOptions: CameraOptions(
//                 center: Point(
//                   coordinates: Position(
//                     _currentPosition!.longitude,
//                     _currentPosition!.latitude,
//                   ),
//                 ),
//                 zoom: 15,
//               ),
//               onMapCreated: _onMapCreated,
//             )
//           : const Center(child: CircularProgressIndicator()),
//       floatingActionButton: hasPos
//           ? FloatingActionButton(
//               onPressed: () {
//                 if (_mapboxMap == null || _currentPosition == null) return;
//                 _mapboxMap!.easeTo(
//                   CameraOptions(
//                     center: Point(
//                       coordinates: Position(
//                         _currentPosition!.longitude,
//                         _currentPosition!.latitude,
//                       ),
//                     ),
//                     zoom: 15,
//                   ),
//                   MapAnimationOptions(duration: 400),
//                 );
//               },
//               child: const Icon(Icons.my_location),
//             )
//           : null,
//     );
//   }

//   @override
//   void dispose() {
//     _posSub?.cancel();
//     super.dispose();
//   }
// }
import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userSetupCubit = context.read<Usersetupcubit>();
    userSetupCubit.stratTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // التطبيق اتقفل أو راح في الخلفية
        userSetupCubit.stopTracking();
        break;
      case AppLifecycleState.resumed:
        // التطبيق رجع تاني
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

    // تفعيل مؤشر الموقع النابض
    await _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    // أول ما يفتح يروح على موقعي بزوم مناسب
    _goToMyLocation();
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
              // this is MAP
              MapWidget(
                styleUri: MapboxStyles.DARK,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(lng!, lat!)),
                  zoom: 17,
                ),
                onMapCreated: _onMapCreated,
              ),
           
           // SEARCH TEXT FILED
           SafeArea(
            child: Material(
              elevation: 5,
              borderRadius:BorderRadius.circular(8) ,
              child: Container(
                         decoration: BoxDecoration(
                          color: Colors.white ,
                          borderRadius: BorderRadius.circular(8),
                         ),
              ),
            )
            
            )

            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
