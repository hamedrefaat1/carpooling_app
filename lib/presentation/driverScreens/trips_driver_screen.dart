import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementCubit.dart';
import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementStates.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/presentation/widgets/buildShimmerTripCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carpooling_app/data/models/trip_model.dart';

class TripsDriverScreen extends StatefulWidget {
  const TripsDriverScreen({super.key});

  @override
  State<TripsDriverScreen> createState() => _TripsDriverScreenState();
}

class _TripsDriverScreenState extends State<TripsDriverScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    // Get driver trips when opening the page
    context.read<DriverTripManagementCubit>().getAllDriverTrips();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.darkBackground
            : AppColors.background,
        appBar: _buildAppBar(isDarkMode),
        body:
            BlocConsumer<DriverTripManagementCubit, DriverTripManagementStates>(
              listener: (context, state) {
                if (state is DriverTripsError) {
                  _showErrorSnackBar(context, state.errorMessage);
                }
              },
              builder: (context, state) {
                if (state is DriverTripsLoading) {
                  return _buildShimmerLoadingState(isDarkMode);
                } else if (state is DriverTripsLoaded) {
                  if (state.trips.isEmpty) {
                    return _buildEmptyState(isDarkMode);
                  } else {
                    return _buildDriverTripsList(
                      state.trips,
                      state.requestsCounts,
                      isDarkMode,
                    );
                  }
                }
                return _buildErrorState(isDarkMode);
              },
            ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 2,
      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.primary,
      foregroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.3),

      title: Text(
        "My Trips",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  // Shimmer loading state
  Widget _buildShimmerLoadingState(bool isDarkMode) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: BuildShimmerTripCard(isDarkMode: isDarkMode),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.directions_car,
                size: 80.sp,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No trips yet!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Start by creating your first trip\nand connect with passengers',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create trip
              },
              icon: Icon(Icons.add, size: 20.sp),
              label: Text('Create Trip', style: TextStyle(fontSize: 16.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppColors.error.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Something went wrong!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DriverTripManagementCubit>().getAllDriverTrips();
              },
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text('Try Again', style: TextStyle(fontSize: 16.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverTripsList(
    List<TripModel> trips,
    Map<String, int> requestCounts,
    bool isDarkMode,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DriverTripManagementCubit>().getAllDriverTrips();
      },
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        itemCount: trips.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip, requestCounts, isDarkMode);
        },
      ),
    );
  }

  Widget _buildTripCard(
    TripModel trip,
    Map<String, int> requestCounts,
    bool isDarkMode,
  ) {
    final statusConfig = _getStatusConfig(trip.status, isDarkMode);
    final int requestCount = requestCounts[trip.id] ?? 0;
    final bool hasRequests = requestCount > 0;

    return GestureDetector(
      onTap: () async {
  await Navigator.pushNamed(context, "/TripRequests", arguments: trip.id);
        context.read<DriverTripManagementCubit>().getAllDriverTrips();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () async {
            await Navigator.pushNamed(context, "/TripRequests", arguments: trip.id);
              context.read<DriverTripManagementCubit>().getAllDriverTrips();
            },
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripHeader(trip, statusConfig, isDarkMode),
                  SizedBox(height: 16.h),
                  _buildTripDetails(
                    trip,
                    requestCount,
                    hasRequests,
                    isDarkMode,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTripFooter(trip, isDarkMode),
                      GestureDetector(
                        onTap: () {
                          _deleteTrip(trip, isDarkMode);
                        },
                        child: _buildDeleteBadge(isDarkMode),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripHeader(
    TripModel trip,
    Map<String, dynamic> statusConfig,
    bool isDarkMode,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(Icons.location_on, color: Colors.white, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.destination.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                'Destination',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(statusConfig),
      ],
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusConfig) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: statusConfig['backgroundColor'],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: statusConfig['textColor'],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            statusConfig['label'].toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              color: statusConfig['textColor'],
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails(
    TripModel trip,
    int requestCount,
    bool hasRequests,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            icon: Icons.event_seat,
            label: 'Available Seats',
            value: '${trip.availableSeats}/${trip.maxPassengers}',
            color: AppColors.success,
            isDarkMode: isDarkMode,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: hasRequests
              ? _buildRequestsBadge(requestCount)
              : _buildInfoItem(
                  icon: Icons.people_outline,
                  label: 'Requests',
                  value: '$requestCount',
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  isDarkMode: isDarkMode,
                ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsBadge(int requestCount) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.white, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Requests',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Tap to view',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 1,
          top: 1,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(minWidth: 14.w, minHeight: 14.h),
            child: Text(
              requestCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripFooter(TripModel trip, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            'Created ${_formatDate(trip.createdAt)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBadge(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.delete_outline,
            color: isDarkMode ? Colors.white : AppColors.error,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            'Delete',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDarkMode ? Colors.white : AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTrip(TripModel trip, bool isDarkMode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: isDarkMode
              ? AppColors.darkSurface
              : AppColors.surface,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 50.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Are you sure?",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Do you really want to delete the trip to ${trip.destination.name}?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text("Cancel", style: TextStyle(fontSize: 14.sp)),
                    ),
                    // Delete Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement actual delete trip logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text("Delete", style: TextStyle(fontSize: 14.sp)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatusConfig(String status, bool isDarkMode) {
    switch (status) {
      case 'active':
        return {
          'backgroundColor': isDarkMode
              ? AppColors.success.withOpacity(0.2)
              : AppColors.success.withOpacity(0.1),
          'textColor': AppColors.success,
          'label': 'Active',
        };
      case 'completed':
        return {
          'backgroundColor': isDarkMode
              ? AppColors.info.withOpacity(0.2)
              : AppColors.info.withOpacity(0.1),
          'textColor': AppColors.info,
          'label': 'Completed',
        };
      case 'cancelled':
        return {
          'backgroundColor': isDarkMode
              ? AppColors.error.withOpacity(0.2)
              : AppColors.error.withOpacity(0.1),
          'textColor': AppColors.error,
          'label': 'Cancelled',
        };
      default:
        return {
          'backgroundColor': isDarkMode
              ? AppColors.warning.withOpacity(0.2)
              : AppColors.warning.withOpacity(0.1),
          'textColor': AppColors.warning,
          'label': 'Pending',
        };
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago";
    }
    return "Just now";
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ),
    );
  }
}
