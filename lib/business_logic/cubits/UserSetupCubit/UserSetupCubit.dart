


import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupStates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class Usersetupcubit extends Cubit<UserSetupStates> {
 final FirebaseAuth auth;
 final  FirebaseFirestore firestore; 
  Usersetupcubit(this.auth , this.firestore) : super(UserSetupIntial());

 Future<void> requestLocationAndSetup(String userType)async{

    try {
        emit(UserSetupLoading());
        // هنحدد الموقع الاول يا صاحبي 
        LocationPermission permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied){
          emit(UserSetupError("the Permisson Loaction is denied"));
          return;
        }
        Position position = await Geolocator.getCurrentPosition(
         desiredAccuracy : LocationAccuracy.high,
        );

        // هنجيب بقا رقم التلفون وال uid 
        String uid = auth.currentUser!.uid;
        String phone= auth.currentUser!.phoneNumber!;

        // هنروح نحط معلومات اليوزر في الفاير استور في الداتا بيز 
        await firestore.collection("Users").doc(uid).set({
                "phone": phone,
        "type": userType,
        "location": {
          "lat": position.latitude,
          "lng": position.longitude,
        },
        "createdAt": FieldValue.serverTimestamp(),
        });
          // المعلومات وصلت وخلاص ؟ طب تمام حدث الحاله بتاعتنا بقا 
        emit(UserSetupSuccessed());
    } catch (e) {
       emit(UserSetupError(e.toString()));
    }
 }


}