import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/presentation/driverScreens/Trip_Requests.dart';
import 'package:carpooling_app/presentation/driverScreens/driver_profile_screen.dart';
import 'package:carpooling_app/presentation/driverScreens/home_app_driver.dart';
import 'package:carpooling_app/presentation/driverScreens/trips_driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

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

  // مفاتيح منفصلة لكل Navigator
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    pages = [
      _buildNavigator(0, DriverProfileScreen()),
      _buildNavigator(1, HomeappDriver()),
      _buildNavigator(2, TripsDriverScreen(), {
        "/TripRequests": (context) => TripRequests(
          tripId: ModalRoute.of(context)!.settings.arguments as String,
        ),
      }),
    ];
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

  Widget _buildNavigator(
    int index,
    Widget child, [
    Map<String, WidgetBuilder>? routes,
  ]) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        if (settings.name == Navigator.defaultRouteName) {
          return MaterialPageRoute(builder: (_) => child);
        }
        if (routes != null && routes.containsKey(settings.name)) {
          return MaterialPageRoute(
            builder: routes[settings.name]!,
            settings: settings,
          );
        }
        return null;
      },
    );
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
        unselectedItemColor: isDarkMode
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
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
            icon: Icon(Iconsax.car),
            activeIcon: Icon(Iconsax.car),
            label: "My Trips",
          ),
        ],
      ),
    );
  }
}
