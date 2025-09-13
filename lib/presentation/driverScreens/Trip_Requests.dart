// ignore_for_file: must_be_immutable

import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementCubit.dart';
import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementStates.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:carpooling_app/presentation/widgets/buildShimmerRequestCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TripRequests extends StatefulWidget {
  String tripId;
  TripRequests({super.key, required this.tripId});

  @override
  State<TripRequests> createState() => _TripRequestsState();
}

class _TripRequestsState extends State<TripRequests>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    context.read<DriverTripManagementCubit>().getAllTripRequests(widget.tripId);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
        appBar: _buildAppBar(isDarkMode),
        body: BlocConsumer<DriverTripManagementCubit, DriverTripManagementStates>(
          listener: (context, state) async {
            if (state is TripRequestsError) {
              _showSnackBar(
                context,
                state.errorMessage,
                AppColors.error,
                Icons.error_outline,
                isDarkMode,
              );
            } else if (state is RequestActionSuccess) {
              _showSnackBar(
                context,
                state.message,
                AppColors.success,
                Icons.check_circle_outline,
                isDarkMode,
              );
              await context
                  .read<DriverTripManagementCubit>()
                  .getAllTripRequests(widget.tripId);
            } else if (state is RequestActionError) {
              _showSnackBar(
                context,
                state.errorMessage,
                AppColors.error,
                Icons.error_outline,
                isDarkMode,
              );
            }
          },
          builder: (context, state) {
            if (state is TripRequestsLoading) {
              return _buildLoadingState(isDarkMode);
            }
      
            if (state is TripRequestsLoaded) {
              return _buildLoadedState(state, isDarkMode);
            }
      
            if (state is RequestActionLoading) {
              return _buildProcessingState(isDarkMode);
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 18.sp,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Trip Requests",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }



  Widget _buildLoadingState(bool isDarkMode) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      itemCount: 2,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return BuildShimmerRequestCard(isDarkMode: isDarkMode);
      },
    );
  }



  Widget _buildProcessingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Processing request...",
            style: TextStyle(
              fontSize: 16.sp,
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(TripRequestsLoaded state, bool isDarkMode) {
    if (state.requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: "No requests yet!",
        subtitle: "Passenger requests will appear here",
        isDarkMode: isDarkMode,
      );
    }

    List<JoinRequest> requests = state.requests
        .where((request) => request.status != 'rejected')
        .toList();

    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: "All requests processed!",
        subtitle: "You've handled all incoming requests",
        isDarkMode: isDarkMode,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context
            .read<DriverTripManagementCubit>()
            .getAllTripRequests(widget.tripId);
      },
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        itemCount: requests.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final request = requests[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _buildRequestItem(
              request,
              state.ridersData[request.riderId],
              isDarkMode,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
  }) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(isDarkMode ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                icon,
                size: 64.sp,
                color: AppColors.primary.withOpacity(isDarkMode ? 0.5 : 0.4),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
                color: AppColors.error.withOpacity(isDarkMode ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppColors.error.withOpacity(isDarkMode ? 0.5 : 0.4),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Something went wrong!",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<DriverTripManagementCubit>()
                    .getAllTripRequests(widget.tripId);
              },
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text("Try Again", style: TextStyle(fontSize: 16.sp)),
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

  Widget _buildRequestItem(
    JoinRequest request,
    Map<String, dynamic>? riderInfo,
    bool isDarkMode,
  ) {
    final DriverTripManagementCubit tripCubit =
        context.read<DriverTripManagementCubit>();

    bool isPending = request.status == 'pending';
    bool isAccepted = request.status == 'accepted';

    final riderRating = riderInfo?["rating"]?.toDouble() ?? 4.5;
    final ratingCount = riderInfo?["ratingCount"]?.toInt() ?? 12;

    return Container(
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
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequestHeader(request, riderInfo, riderRating, ratingCount, isDarkMode),
              SizedBox(height: 20.h),
              _buildRequestInfo(request, isDarkMode),
              if (isPending || isAccepted) ...[
                SizedBox(height: 20.h),
                _buildActionButtons(request, tripCubit, isPending, isAccepted , isDarkMode,)
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestHeader(
    JoinRequest request,
    Map<String, dynamic>? riderInfo,
    double riderRating,
    int ratingCount,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Icon(
            Icons.person,
            size: 28.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 16.w),
        
        // Rider Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      riderInfo?["fullName"] ?? "Unknown Rider",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _buildStatusBadge(request.status, isDarkMode),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  // Rating
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(isDarkMode ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14.sp, color: AppColors.warning),
                        SizedBox(width: 4.w),
                        Text(
                          riderRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "($ratingCount)",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.warning.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Personal Info
                  Text(
                    "${riderInfo?["gender"] ?? "N/A"} • ${riderInfo?["age"] ?? "--"} years",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isDarkMode) {
    final statusConfig = _getStatusConfig(status, isDarkMode);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusConfig['backgroundColor'],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          color: statusConfig['textColor'],
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRequestInfo(JoinRequest request, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16.sp,
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Text(
            "Requested ${_formatDate(request.requestedAt)}",
            style: TextStyle(
              fontSize: 13.sp,
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    JoinRequest request,
    DriverTripManagementCubit tripCubit,
    bool isPending,
    bool isAccepted,
    bool isDarkMode,
  ) {
    if (isPending) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _animationController.forward();
                tripCubit.handleRequestAction(widget.tripId, request.id, 'accept');
              },
              icon: Icon(Icons.check_circle, size: 18.sp),
              label: Text("Accept", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                tripCubit.handleRequestAction(widget.tripId, request.id, 'rejected');
              },
              icon: Icon(Icons.cancel, size: 18.sp , color: isDarkMode ? Colors.white : AppColors.error, ),
              label: Text("Decline", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600 , color:  isDarkMode ? Colors.white : AppColors.error, )),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(isDarkMode ? 0.2 : 0.1),
                foregroundColor: AppColors.error.withOpacity(isDarkMode ? 0.2 : 0.1),
                side: BorderSide(color: AppColors.error.withOpacity(isDarkMode ? 0.2 : 0.1), width: 1.5.w),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isAccepted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigate to chat screen
          },
          icon: Icon(Icons.chat_bubble, size: 18.sp),
          label: Text("Start Chat", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Map<String, Color> _getStatusConfig(String status, bool isDarkMode) {
    switch (status) {
      case "pending":
        return {
          'backgroundColor': isDarkMode 
              ? AppColors.warning.withOpacity(0.2) 
              : AppColors.warning.withOpacity(0.1),
          'textColor': AppColors.warning,
        };
      case "accepted":
        return {
          'backgroundColor': isDarkMode 
              ? AppColors.success.withOpacity(0.2) 
              : AppColors.success.withOpacity(0.1),
          'textColor': AppColors.success,
        };
      case "rejected":
        return {
          'backgroundColor': isDarkMode 
              ? AppColors.error.withOpacity(0.2) 
              : AppColors.error.withOpacity(0.1),
          'textColor': AppColors.error,
        };
      default:
        return {
          'backgroundColor': isDarkMode 
              ? AppColors.textSecondary.withOpacity(0.2) 
              : AppColors.textSecondary.withOpacity(0.1),
          'textColor': AppColors.textSecondary,
        };
    }
  }

  String _formatDate(DateTime date) {
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

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
    bool isDarkMode,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
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
        backgroundColor: backgroundColor,
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