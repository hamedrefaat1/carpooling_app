import 'dart:async';

import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupStates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class Usersetupcubit extends Cubit<UserSetupStates> {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  StreamSubscription<Position>? _positionStream;

  Usersetupcubit(this.auth, this.firestore) : super(UserSetupIntial());

  Future<void> requestLocationAndSetup(String userType) async {
    try {
      if (isClosed) return;
      emit(UserSetupLoading());

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!isClosed) emit(UserSetupError("the Permission Location is denied"));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String uid = auth.currentUser!.uid;
      String phone = auth.currentUser!.phoneNumber!;

      await firestore.collection("Users").doc(uid).set({
        "phone": phone,
        "type": userType,
        "location": {"lat": position.latitude, "lng": position.longitude},
        "status": "online",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!isClosed) emit(UserSetupSuccessed());
    } catch (e) {
      if (!isClosed) emit(UserSetupError(e.toString()));
    }
  }

  Future<void> stratTracking() async {
    try {
      if (isClosed) return;
      emit(UserSetupLoading());

      String uid = auth.currentUser!.uid;
      await firestore.collection("Users").doc(uid).update({"status": "online"});

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position pos) async {
        await firestore.collection("Users").doc(uid).update({
          "location": {"lat": pos.latitude, "lng": pos.longitude},
          "lastUpdated": FieldValue.serverTimestamp(),
        });
      });

      if (!isClosed) emit(UserSetupSuccessed());
    } catch (e) {
      if (!isClosed) emit(UserSetupError(e.toString()));
    }
  }

  Future<void> stopTracking() async {
    try {
      // أوقف الـ stream أول حاجة
      if (_positionStream != null) {
        await _positionStream!.cancel();
        _positionStream = null;
      }

      String uid = auth.currentUser!.uid;
      await firestore.collection("Users").doc(uid).update({
        "status": "offline",
      });

      if (!isClosed) emit(UserSetupSuccessed());
    } catch (e) {
      if (!isClosed) emit(UserSetupError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _positionStream?.cancel();
    _positionStream = null;
    return super.close();
  }
}
