import 'package:carpooling_app/constants/constStrings.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/firebase_options.dart';
import 'package:carpooling_app/router/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

late String initialRoute;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.authStateChanges().listen(
           ( User? user){
               if(user==null){
                   initialRoute = signUpScreen;
               }else{
                initialRoute = homeScreen;
               }
           }
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
      builder: (_, child){
        return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter().generateRoute,
        initialRoute: initialRoute,
        home:child ,
      );
      },
      
    );
  }
}
