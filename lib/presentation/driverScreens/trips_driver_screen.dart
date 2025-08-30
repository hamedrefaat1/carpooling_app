import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementCubit.dart';
import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementStates.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carpooling_app/data/models/trip_model.dart';

class TripsDriverScreen extends StatefulWidget {
  const TripsDriverScreen({super.key});

  @override
  State<TripsDriverScreen> createState() => _TripsDriverScreenState();
}

class _TripsDriverScreenState extends State<TripsDriverScreen> {
  @override
  void initState() {
    super.initState();
    // get dviver trips when opening the page
    context.read<DriverTripManagementCubit>().getAllDriverTrips();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white12,
        appBar: AppBar(
          title: const Text('My Trips'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                // Refresh trips
                context.read<DriverTripManagementCubit>().getAllDriverTrips();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocConsumer<DriverTripManagementCubit, DriverTripManagementStates>(
          listener: (context, state) {
            if (state is DriverTripsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DriverTripsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            } else if (state is DriverTripsLoaded) {
              if (state.trips.isEmpty) {
                return _bulidNotTripsYet();
              } else {
                return _buildDriverTripsList(state.trips, state.requestsCounts);
              }
            }
            return const Center(child: Text('Something went wrong!'));
          },
        ),
      ),
    );
  }

  Widget _bulidNotTripsYet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 100, color: Colors.grey[300]),
          SizedBox(height: 20.h),
          Text(
            'No trips created yet.',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverTripsList(
    List<TripModel> trips,
    Map<String, int> requestCounts,
  ) {
    return ListView.builder(
      itemCount: trips.length,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      itemBuilder: (context, index) {
        final trip = trips[index];

        // ----- status Color-------
        Color statusColor;
        switch (trip.status) {
          case 'active':
            statusColor = Colors.green;
            break;
          case 'completed':
            statusColor = Colors.blueGrey;
            break;
          case 'cancelled':
            statusColor = Colors.redAccent;
            break;
          default:
            statusColor = Colors.orangeAccent;
        }
        // ----- have any requestes -----
        int requestCount = requestCounts[trip.id] ?? 0;
        bool hasRequests = requestCount > 0;
        return GestureDetector(
          onTap: () async {
            await Navigator.pushNamed(
              context,
              "/TripRequests",
              arguments: trip.id,
            );
            // Refresh trips after returning from requests screen
            context.read<DriverTripManagementCubit>().getAllDriverTrips();
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --------- Destination & Status Row ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 20.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "To ${trip.destination.name}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          trip.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  //--------- Seats & Requests Info ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_seat,
                            color: Colors.grey.shade700,
                            size: 18.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${trip.availableSeats}/${trip.maxPassengers} seats",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),

                      hasRequests
                          ? GestureDetector(
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  "/TripRequests",
                                  arguments: trip.id,
                                );
                                // Refresh trips after returning from requests screen
                                context
                                    .read<DriverTripManagementCubit>()
                                    .getAllDriverTrips();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(6.w),
                                        child: Text(
                                          "${requestCounts[trip.id] ?? 0} ",
                                          style: TextStyle(
                                            fontSize: 6.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "requests",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.grey.shade700,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${requestCounts[trip.id] ?? 0} requests",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // --------- Created At ----------
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey.shade600,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        trip.createdAt != null
                            ? _fomatDate(trip.createdAt!)
                            : "Unknown Date",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _fomatDate(DateTime date) {
    final timeNow = DateTime.now();
    final diffrance = timeNow.difference(date);
    if (diffrance.inDays > 0) {
      return "${diffrance.inDays}d ago";
    } else if (diffrance.inHours > 0) {
      return "${diffrance.inHours}h ago";
    } else if (diffrance.inMinutes > 0) {
      return "${diffrance.inMinutes}m ago";
    } else {
      return "Just Now";
    }
  }
}
