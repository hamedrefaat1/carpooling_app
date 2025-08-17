import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/presentation/driverScreens/driver_profile_screen.dart';
import 'package:carpooling_app/presentation/driverScreens/home_app_driver.dart';
import 'package:carpooling_app/presentation/driverScreens/trips_driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverMainShell extends StatefulWidget {
  const DriverMainShell({super.key});

  @override
  State<DriverMainShell> createState() => _DriverMainShellState();
}

class _DriverMainShellState extends State<DriverMainShell>
    with WidgetsBindingObserver {
  int currentIndex = 1;
  late Usersetupcubit usersetupcubit;

  late List<Widget> pages;

  @override
  void initState() {
    pages = [DriverProfileScreen(), HomeappDriver(), TripsDriverScreen()];

    WidgetsBinding.instance.addObserver(this);
    usersetupcubit = context.read<Usersetupcubit>();
    usersetupcubit.stratTracking();

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        usersetupcubit.stopTracking();
        break;
      case AppLifecycleState.resumed:
        usersetupcubit.stratTracking();

        break;
      default:
        break;
    }
  }

  void onNavBarTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: __buildBottomNavBar(),
    );
  }

  Widget __buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[900],
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
        ),
        items: [
       

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
             BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route_outlined),
            activeIcon: Icon(Icons.route),
            label: "My Trips",
          ),
        ],
      ),
    );
  }
}
