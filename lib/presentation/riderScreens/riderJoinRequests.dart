import 'package:carpooling_app/business_logic/cubits/riderJoinRequests.dart/riderJoinRequestsCubit.dart';
import 'package:carpooling_app/business_logic/cubits/riderJoinRequests.dart/riderJoinRequestsStates.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/data/models/riderRiderRequestWithTripData.dart';
import 'package:carpooling_app/presentation/widgets/ChatDialog.dart';
import 'package:carpooling_app/presentation/widgets/buildShimmerJoinRequestCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RiderJoinRequestsScreen extends StatefulWidget {
  const RiderJoinRequestsScreen({super.key});

  @override
  State<RiderJoinRequestsScreen> createState() =>
      _RiderJoinRequestsScreenState();
}

class _RiderJoinRequestsScreenState extends State<RiderJoinRequestsScreen> {
  String riderId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    // Fetch requests when screen loads
    context.read<RiderJoinRequestsCubit>().getRiderJoinRequests(riderId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

 

    return Scaffold(
      appBar: _buildAppBar(isDarkMode),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.darkBackground, AppColors.darkSurface],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.background,
                  ],
                ),
        ),
        child: BlocConsumer<RiderJoinRequestsCubit, RiderJoinRequestsStates>(
          listener: (context, state) {
            if (state is RiderJoinRequestsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage.toString()),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RiderJoinRequestsLoading) {
              return _buildLoadingState(isDarkMode);
            }

            if (state is RiderJoinRequestsLoaded) {
              if (state.requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 60.sp,
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textLight,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No requests yet!",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Your join requests will appear here",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context
                      .read<RiderJoinRequestsCubit>()
                      .getRiderJoinRequests(riderId);
                },
                child: ListView.separated(
                  padding: EdgeInsets.all(12.w),
                  itemCount: state.requests.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final RiderRequestWithTripData requestData =
                        state.requests[index];
                    return _buildRequestItem(requestData, isDarkMode);
                  },
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 50.sp,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textLight,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Something went wrong!",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<RiderJoinRequestsCubit>()
                          .getRiderJoinRequests(riderId);
                    },
                    child: Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      itemCount: 2,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return BuildShimmerJoinRequestCard(isDarkMode: isDarkMode);
      },
    );
  }

  // bulid app bar
  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 2,
      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.primary,
      foregroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.3),

      title: Text(
        "My Requests",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build each request card with modern UI
  Widget _buildRequestItem(RiderRequestWithTripData data, bool isDarkMode) {
    final status = data.request.status;
    Color statusColor = AppColors.textLight;
    IconData statusIcon = Icons.access_time;

    switch (status) {
      case "pending":
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time;
        break;
      case "accepted":
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case "rejected":
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
    }

    // Get driver rating from driverData or use default
    final driverRating = data.driverData["rating"]?.toDouble() ?? 4.5;
    final ratingCount = data.driverData["ratingCount"]?.toInt() ?? 24;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver info and status
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.primaryLight.withOpacity(0.3),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 30.sp,
                    color: isDarkMode
                        ? AppColors.primaryLight
                        : AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.driverData["fullName"] ?? "Unknown Driver",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Rating row with star icon and rating count
                      Row(
                        children: [
                          Icon(Icons.star, size: 14.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            driverRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "($ratingCount)",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14.sp,
                            color: isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.textLight,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              data.tripData.destination.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: statusColor.withOpacity(isDarkMode ? 0.4 : 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14.sp, color: statusColor),
                      SizedBox(width: 4.w),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Trip details
            Row(
              children: [
                Icon(
                  Icons.event_seat,
                  size: 16.sp,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textLight,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Seats: ${data.tripData.availableSeats}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textLight,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.group,
                  size: 16.sp,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textLight,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Max: ${data.tripData.maxPassengers}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16.sp,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textLight,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Passengers: ${data.tripData.passengers.length}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textLight,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.circle,
                  size: 16.sp,
                  color: _getStatusColor(data.tripData.status, isDarkMode),
                ),
                SizedBox(width: 8.w),
                Text(
                  data.tripData.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getStatusColor(data.tripData.status, isDarkMode),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Request time + Actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Requested: ${_formatRequestTime(data.request.requestedAt)}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.textLight,
                    ),
                  ),
                ),
                if (status == "pending")
                  ElevatedButton(
                    onPressed: () {
                      _showCancelDialog(context, data, isDarkMode);
                    },
                    child: Text("Cancel", style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppColors.error.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.1),
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(
                          color: AppColors.error.withOpacity(
                            isDarkMode ? 0.4 : 0.3,
                          ),
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                if (status == "accepted") ...[
                  SizedBox(width: 10.w),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to Chat Screen
                      _showChatDialog(context, data, isDarkMode);
                    },
                    icon: Icon(Icons.chat, size: 18.sp),
                    label: Text("Chat", style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status) {
      case "active":
        return AppColors.success;
      case "completed":
        return isDarkMode ? AppColors.primaryLight : AppColors.primary;
      case "cancelled":
        return AppColors.error;
      default:
        return isDarkMode ? AppColors.darkTextSecondary : AppColors.textLight;
    }
  }

  String _formatRequestTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    }
    return "Just now";
  }

  void _showCancelDialog(
    BuildContext context,
    RiderRequestWithTripData data,
    bool isDarkMode,
  ) {
    final cubit = BlocProvider.of<RiderJoinRequestsCubit>(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
          title: Text(
            "Cancel Join Request",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          content: Text(
            "Are you sure you want to cancel this join request?",
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "No",
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                cubit.cancleJoinRequest(data.tripData.id!, data.request.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Request cancelled successfully"),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              },
              child: Text(
                "Yes, Cancel",
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
   void _showChatDialog(BuildContext context, RiderRequestWithTripData data, bool isDarkMode) {
  showDialog(
    context: context,
    builder: (context) => ChatDialog(
      tripId: data.tripData.id!,
      requestId: data.request.id,
      otherUserId: data.tripData.driverId,
      otherUserName: data.driverData["fullName"] ?? "Unknown Driver",
      userType: "passenger",
    ),
  );
}
}
