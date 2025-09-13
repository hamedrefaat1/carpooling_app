// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class BuildShimmerTripCard extends StatelessWidget {
  final bool isDarkMode;
  const BuildShimmerTripCard( {super.key , required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return    Shimmer.fromColors(
    baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
    highlightColor: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade100,
    period: const Duration(milliseconds: 1200),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // 
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120.w,
                      height: 16.h,
                      color: Colors.white, 
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 80.w,
                      height: 12.h,
                      color: Colors.white, 
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12.r),
                ),
                width: 73.w,
                height: 30.h,
                
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Details
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12.r),
                ),
                  height: 50.h,
                  
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12.r),
                ),
                  height: 50.h,
                
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12.r),
                ),
                width: 140.w,
                height: 25.h,
               
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12.r),
                ),
                width: 60.w,
                height: 25.h,
               
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}