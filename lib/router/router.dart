import 'package:carpooling_app/constants/constStrings.dart';
import 'package:carpooling_app/presentation/screens/signUp.dart';
import 'package:flutter/material.dart';

class AppRouter{

  Route? generateRoute(RouteSettings settings){
    switch(settings.name){
      case signUpScreen:
      return MaterialPageRoute(
        builder: (_)=> Signup()
      );

      default :
      return null;
    }
  }
}