// تعديل AppRouter لاستخدام static instance
import 'package:carpooling_app/business_logic/cubits/AuthCubit/cubit_auth.dart';
import 'package:carpooling_app/business_logic/cubits/PlaceSearchCubit/place_search_cubit.dart';
import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:carpooling_app/constants/constStrings.dart';
import 'package:carpooling_app/presentation/driverScreens/home_app_driver.dart';
import 'package:carpooling_app/presentation/riderScreens/home_app_rider.dart';
import 'package:carpooling_app/presentation/screens/OTPVerify.dart';
import 'package:carpooling_app/presentation/screens/getUserInfo.dart';
import 'package:carpooling_app/presentation/screens/signUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  
  static final PhoneSignUpCubit _phoneSignUpCubit = PhoneSignUpCubit();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneSignUpCubit>.value(
            value: _phoneSignUpCubit,
            child: Signup(),
          ),
        );

      case verifyPhoneScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneSignUpCubit>.value(
            value: _phoneSignUpCubit,
            child: VerifyPhoneScreen(phoneNumber: settings.arguments as String),
          ),
        );
      
       case getUserInfo : 
       return MaterialPageRoute(builder: (_)=> BlocProvider<Usersetupcubit>(create: (_)=> Usersetupcubit(auth, firestore) ,
          child: GetUserInfo()
       )
          
       );
      case homeAppDriver:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<Usersetupcubit>(
                create: (_) => Usersetupcubit(auth, firestore),
              ),
              BlocProvider<PlaceSearchCubit>.value(
                value: PlaceSearchCubit(),
              ),
            ],
            child: HomeappDriver(),
          ),
        );

        case homeAppRider:
        return MaterialPageRoute(builder: (_)=> HomeAppRider());

          
       
      default:
        return null;
    }
  }
  

  void dispose() {
    _phoneSignUpCubit.close();
  }
}