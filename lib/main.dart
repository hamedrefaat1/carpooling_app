import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/firebase_options.dart';
import 'package:carpooling_app/presentation/screens/signUp.dart';
import 'package:carpooling_app/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CarpoolingApp());
}

class CarpoolingApp extends StatelessWidget {
  const CarpoolingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
       designSize: const Size(360, 690),
      builder: (_, child){
        return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter().generateRoute,
        home:child ,
      );
      },
      child: Signup(),
    );
  }
}
