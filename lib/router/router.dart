// تعديل AppRouter لاستخدام static instance
import 'package:carpooling_app/business_logic/cubits/cubitAuth/cubit_auth.dart';
import 'package:carpooling_app/constants/constStrings.dart';
import 'package:carpooling_app/presentation/screens/OTPVerify.dart';
import 'package:carpooling_app/presentation/screens/homeScreen.dart';
import 'package:carpooling_app/presentation/screens/signUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  
  static final PhoneSignUpCubit _phoneSignUpCubit = PhoneSignUpCubit();
  
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
      
       case homeScreen : 
       return MaterialPageRoute(builder: (_)=> HomeScreen());
      default:
        return null;
    }
  }
  

  void dispose() {
    _phoneSignUpCubit.close();
  }
}