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
import 'package:flutter_dotenv/flutter_dotenv.dart';

late String initialRoute;
late String userType;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await dotenv.load(fileName: ".env");

  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // determine initial route based on authentication state
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
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userType = userData["type"];

      if (userType == "driver") {
        initialRoute = driverMainShell;
      } else {
        initialRoute = riderMainShell;
      }
    }
  }

  
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);

  runApp(const CarpoolingApp());
}

class CarpoolingApp extends StatelessWidget {
  const CarpoolingApp({super.key});

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
