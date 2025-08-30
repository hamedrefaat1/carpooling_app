// ignore_for_file: must_be_immutable

import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementCubit.dart';
import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementStates.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripRequests extends StatefulWidget {
  String tripId;
  TripRequests({super.key, required this.tripId});

  @override
  State<TripRequests> createState() => _TripRequestsState();
}

class _TripRequestsState extends State<TripRequests> {
  @override
  void initState() {
    context.read<DriverTripManagementCubit>().getAllTripRequests(widget.tripId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trip Requests"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body:
            BlocConsumer<DriverTripManagementCubit, DriverTripManagementStates>(
              listener: (context, state) async {
                if (state is TripRequestsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }else if(state is RequestActionSuccess ) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // refresh requests list
                await  context.read<DriverTripManagementCubit>().getAllTripRequests(widget.tripId);
                }
                else if( state is RequestActionError ){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TripRequestsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }
                if (state is TripRequestsLoaded) {
                  if (state.requests.isEmpty) {
                    return const Center(child: Text("No Requests Yet!"));
                  } else {
                    List<JoinRequest> requests = state.requests.where((request) => request.status != 'rejected').toList();
                    if(requests.isEmpty){
                      return const Center(child: Text("No Requests Yet!"));
                    }else{
                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = state.requests[index];
                        return _buildRequestItem(
                          request,
                          state.ridersData[request.riderId],
                        );
                      },
                    );
                    }
                  }
                } else if(state is RequestActionLoading){
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }
                return const Center(child: Text("Something went wrong!"));
              },
            ),
      ),
    );
  }

  Widget _buildRequestItem(
    JoinRequest request,
    Map<String, dynamic> riderInfo,
  ) {
     final DriverTripManagementCubit tripCubit =
        context.read<DriverTripManagementCubit>();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // image profile
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 32.sp, color: Colors.grey),
                ),
                SizedBox(width: 12.w),
                // rider info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riderInfo["fullName"] ?? "Unknown",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${riderInfo["gender"] ?? "N/A"}, ${riderInfo["age"] ?? "--"} yrs",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                
           
              ],
            ),
            SizedBox(height: 12.h),
            // وقت الطلب
            Text(
              "Requested: ${_formatDate(request.requsetedAt)}",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 12.h),
            // أزرار Accept / Decline
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if(request.status == 'pending'){
                      tripCubit.handleRequestAction(widget.tripId, request.id, 'accept');
                    }
                  },
                  icon: request.status == 'pending' ?  Icon(Icons.check, size: 18.sp)  : Icon(Icons.chat, size: 18.sp),
                  label: request.status == 'pending' ?  Text("Accept", style: TextStyle(fontSize: 14.sp)) : Text("chat" , style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: request.status == 'pending' ? Colors.green : Colors.black ,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton.icon(
                  onPressed: () {
                      tripCubit.handleRequestAction(widget.tripId, request.id, 'rejected');
                  },
                  icon: Icon(Icons.close, size: 18.sp),
                  label: Text("Decline", style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    DateTime timeNow = DateTime.now();
    final difference = timeNow.difference(date);
    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    }
    return "Just Now";
  }
}
