// ignore_for_file: use_build_context_synchronously

import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupCubit.dart';
import 'package:carpooling_app/business_logic/cubits/UserSetupCubit/UserSetupStates.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class GetUserInfo extends StatefulWidget {
  const GetUserInfo({super.key});

  @override
  State<GetUserInfo> createState() => _GetUserInfoState();
}

class _GetUserInfoState extends State<GetUserInfo> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedUserType;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _selectedUserType != null) {
      // إنشاء Map بالمعلومات
      Map<String, dynamic> userInfo = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender!,
        'type': _selectedUserType!,
      };

      
      context.read<Usersetupcubit>().requestLocationAndSetupWithInfo(userInfo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<Usersetupcubit, UserSetupStates>(
          listener: (context, state) async {
            if (state is UserSetupLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return Center(child: CircularProgressIndicator());
                },
              );
            }
            if (state is UserSetupError) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(); // loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            if (state is UserSetupSuccessed) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(); // loading dialog

              final uid = FirebaseAuth.instance.currentUser!.uid;
              DocumentSnapshot doc = await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(uid)
                  .get();

              String type = doc.get("type");
              if (type == "driver") {
                Navigator.pushReplacementNamed(context, "/driverMainShell");
              } else {
                Navigator.pushReplacementNamed(context, "/riderMainSell");
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(),

                  Gap(30.h),

                  // Form Section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // الاسم الأول
                          _buildTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hint: 'Enter your first name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),

                          Gap(16.h),

                          // last name
                          _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hint: 'Enter your last name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),

                          Gap(16.h),

                          // age
                          _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            hint: 'Enter your age',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Age is required';
                              }
                              int? age = int.tryParse(value.trim());
                              if (age == null || age < 18 || age > 100) {
                                return 'Age must be between 18 and 100 years';
                              }
                              return null;
                            },
                          ),

                          Gap(20.h),

                          // ginger
                          _buildGenderSelection(),

                          Gap(20.h),

                          //  user type -> driver or rider
                          _buildUserTypeSelection(),

                          Gap(30.h),

                          // continue botton
                          _buildSubmitButton(),

                          Gap(20.h),

                          // Terms and Privacy
                          Text(
                            "By continuing, you agree to our Terms of Service and Privacy Policy",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textLight,
                                  fontSize: 12.sp,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.directions_car,
            size: 40.sp,
            color: AppColors.primary,
          ),
        ),

        Gap(20.h),

        // Welcome Text
        Text(
          "Welcome to Hopin!",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        Gap(10.h),

        Text(
          "Let's get to know you better",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(12.h),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                icon: Icons.man,
                title: 'Male',
                isSelected: _selectedGender == 'male',
                onTap: () {
                  setState(() {
                    _selectedGender = 'male';
                  });
                },
              ),
            ),
            Gap(12.w),
            Expanded(
              child: _buildSelectionCard(
                icon: Icons.woman,
                title: 'Female',
                isSelected: _selectedGender == 'female',
                onTap: () {
                  setState(() {
                    _selectedGender = 'female';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(12.h),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                icon: Icons.drive_eta,
                title: 'Driver',
                isSelected: _selectedUserType == 'driver',
                color: AppColors.driverColor,
                onTap: () {
                  setState(() {
                    _selectedUserType = 'driver';
                  });
                },
              ),
            ),
            Gap(12.w),
            Expanded(
              child: _buildSelectionCard(
                icon: Icons.person,
                title: 'Passenger',
                isSelected: _selectedUserType == 'Passenger',
                color: AppColors.passengerColor,
                onTap: () {
                  setState(() {
                    _selectedUserType = 'Passenger';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    Color cardColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? cardColor.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? cardColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30.sp,
              color: isSelected ? cardColor : AppColors.textSecondary,
            ),
            Gap(8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? cardColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
