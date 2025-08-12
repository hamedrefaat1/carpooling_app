import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
              child: Column(
                children: [
                  // Header Section
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon/Logo placeholder
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            size: 50.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        
                        Gap(30.h),
                        
                        // Welcome Text
                        Text(
                          "Welcome to Hopin!",
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Gap(15.h),
                        
                        Text(
                          "Choose how you want to use the app",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Gap(15.h),
                  // Selection Cards Section
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Driver Card
                        _UserTypeCard(
                          icon: Icons.drive_eta,
                          title: "I'm a Driver",
                          subtitle: "Share your car and earn money",
                          color: AppColors.driverColor,
                          onTap: () {
                           // context.read<UserSetupCubit>().requestLocationAndSetup(UserType.driver);
                          },
                        ),
                        
                        Gap(20.h),
                        
                        // Passenger Card
                        _UserTypeCard(
                          icon: Icons.person,
                          title: "I'm a Passenger",
                          subtitle: "Find rides and save money",
                          color: AppColors.passengerColor,
                          onTap: () {
                          //  context.read<UserSetupCubit>().requestLocationAndSetup(UserType.passenger);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Loading Section
                 
                  
                  Gap(20.h),
                  
                  // Terms and Privacy
                  Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 30.sp,
                color: color,
              ),
            ),
            
            Gap(16.w),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 18.sp,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

