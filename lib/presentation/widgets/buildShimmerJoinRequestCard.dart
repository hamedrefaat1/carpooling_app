import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class BuildShimmerJoinRequestCard extends StatelessWidget {
  final bool isDarkMode;
  const BuildShimmerJoinRequestCard({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
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
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    // borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 9.h,
                        width: 90.w,
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        height: 9.h,
                        width: 40.w,
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        height: 9.h,
                        width: 40.w,
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 40.h,
                    width: 110.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Details
            Row(
              children: [
                Container(
                  height: 15.h,
                  width: 70.w,
                  decoration: BoxDecoration(color: Colors.white),
                ),
                Spacer(),
                Container(
                  height: 15.h,
                  width: 70.w,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  height: 15.h,
                  width: 70.w,
                  decoration: BoxDecoration(color: Colors.white),
                ),
                Spacer(),
                Container(
                  height: 15.h,
                  width: 70.w,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ],
            ),

             SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  height: 15.h,
                  width: 70.w,
                  decoration: BoxDecoration(color: Colors.white),
                ),
                Spacer(),
                Container(
                  height: 40.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
