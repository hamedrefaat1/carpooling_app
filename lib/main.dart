import 'package:carpooling_app/constants/constStrings.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/firebase_options.dart';
import 'package:carpooling_app/router/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

late String initialRoute;
late String userType;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  User? user = await FirebaseAuth.instance.authStateChanges().first;

  if (user == null) {
    initialRoute = signUpScreen;
  } else {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get();
    if (!userDoc.exists) {
      initialRoute = getUserInfo;
    } else {
      Map<String, dynamic> userDate = userDoc.data() as Map<String, dynamic>;
      userType = userDate["type"];

      if (userType == "driver") {
        initialRoute = driverMainShell;
      } else {
        initialRoute = riderMainShell;
      }
    }
  }

  //await setUp();
  MapboxOptions.setAccessToken(
    "REMOVED",
  );
  runApp(const CarpoolingApp());
}

class CarpoolingApp extends StatelessWidget {
  const CarpoolingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter().generateRoute,
          initialRoute: initialRoute,
          home: child,
        );
      },
    );
  }
}
