import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/presentation/riderScreens/home_app_rider.dart';
import 'package:carpooling_app/presentation/riderScreens/riderJoinRequests.dart';
import 'package:carpooling_app/presentation/riderScreens/rider_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class RiderMainShell extends StatefulWidget {
  const RiderMainShell({super.key});

  @override
  State<RiderMainShell> createState() => _RiderMainShellState();
}

class _RiderMainShellState extends State<RiderMainShell>
    with WidgetsBindingObserver {
  int currentIndex = 1;
  late Usersetupcubit usersetupcubit;

  late List<Widget> pages;

  @override
  void initState() {
    pages = [RiderProfileScreen(), HomeAppRider(), RiderJoinRequestsScreen()];

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: __buildBottomNavBar(isDarkMode),
    );
  }

  Widget __buildBottomNavBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
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
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
            label: "My Requests",
          ),
        ],
      ),
    );
  }
}