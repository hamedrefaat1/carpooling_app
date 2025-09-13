
import 'package:carpooling_app/business_logic/cubits/AuthCubit/cubit_auth.dart';
import 'package:carpooling_app/business_logic/cubits/DriverPlacesSearchCubit/driver_places_search_cubit.dart';
import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementCubit.dart';
import 'package:carpooling_app/business_logic/cubits/MapDisplayCubit/MapDisplayCubit.dart';
import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:carpooling_app/business_logic/cubits/requestToJoinTripCubit/requestToJoinTripCubit.dart';
import 'package:carpooling_app/business_logic/cubits/riderJoinRequests.dart/riderJoinRequestsCubit.dart';
import 'package:carpooling_app/constants/constStrings.dart';
import 'package:carpooling_app/presentation/driverScreens/Driver_main_shell.dart';
import 'package:carpooling_app/presentation/driverScreens/Trip_Requests.dart';
import 'package:carpooling_app/presentation/driverScreens/home_app_driver.dart';
import 'package:carpooling_app/presentation/riderScreens/home_app_rider.dart';
import 'package:carpooling_app/presentation/riderScreens/rider_main_shell.dart';
import 'package:carpooling_app/presentation/screens/OTPVerify.dart';
import 'package:carpooling_app/presentation/screens/getUserInfo.dart';
import 'package:carpooling_app/presentation/screens/signUp.dart';
import 'package:carpooling_app/presentation/screens/splashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class AppRouter {
  static final PhoneSignUpCubit _phoneSignUpCubit = PhoneSignUpCubit();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 1000),
          child: SplashScreen(),
        );

      case signUpScreen:
        return PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 1000),
          child: BlocProvider<PhoneSignUpCubit>.value(
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

      case getUserInfo:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<Usersetupcubit>(
            create: (_) => Usersetupcubit(auth, firestore),
            child: GetUserInfo(),
          ),
        );
      case homeAppDriver:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => DriverPlacesSearchCubit(),
            child: HomeappDriver(),
          ),
        );

      case homeAppRider:
        return MaterialPageRoute(builder: (_) => HomeAppRider());

      case driverMainShell:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<Usersetupcubit>(
                create: (_) => Usersetupcubit(auth, firestore),
              ),
              BlocProvider<DriverPlacesSearchCubit>(
                create: (_) => DriverPlacesSearchCubit(),
              ),
              BlocProvider(create: (context) => DriverTripManagementCubit()),
               BlocProvider(create: (context) => MapDisplayCubit()),
            ],
            child: DriverMainShell(),
          ),
        );

      case riderMainShell:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => Usersetupcubit(auth, firestore)),
              BlocProvider(create: (context) => Requesttojointripcubit()),
                BlocProvider(create: (context) => RiderJoinRequestsCubit()),
                   BlocProvider(create: (context) => MapDisplayCubit()),
            ],
            child: RiderMainShell(),
          ),
        );

      case tripRequests:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => DriverTripManagementCubit(),
            child: TripRequests(tripId: settings.arguments as String),
          ),
        );

 
      default:
        return null;
    }
  }

  void dispose() {
    _phoneSignUpCubit.close();
  }
}
