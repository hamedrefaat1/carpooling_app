import 'package:carpooling_app/business_logic/cubits/AuthCubit/cubit_auth.dart';
import 'package:carpooling_app/business_logic/cubits/AuthCubit/state_auth.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumber = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: Scaffold(
          body: Container(
            margin: EdgeInsets.only(top: 100.h, right: 15.w, left: 15.w),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to the Carpooling App",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontSize: 22.sp, // بدل من headlineLarge
                          ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Please enter your phone number to verfiy your account",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 18.sp,
                          ),
                    ),
                    Gap(80.h),
                    Row(
                      children: [
                        Container(
                          height: 50.h,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Text("EG", style: TextStyle(fontSize: 13.sp)),

                              Gap(5.w),
                              Text(
                                "+20",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Gap(5.w),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                        Gap(10.w),
                        Expanded(
                          child: TextFormField(
                            controller: phoneNumber,
                            keyboardType: TextInputType.number,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: "Enter your phone",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your number";
                              }
                              if (value.length < 11) {
                                return "enter a valid number";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    Gap(40.h),
                    BlocListener<PhoneSignUpCubit, PhoneSignup>(
                      listenWhen: (previous, current) {
                        return previous != current;
                      },
                      listener: (context, state) {
                        if (state is PhoneSignupLoading) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is PhoneSignupError) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else if (state is PhoneNumberSubmitted) {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/verifyPhoneScreen',
                            arguments: phoneNumber.text,
                          );
                        }
                      },
                      child: Center(
                        child: ElevatedButton(
                          style: Theme.of(context).elevatedButtonTheme.style
                              ?.copyWith(
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                    horizontal: 70.w,
                                    vertical: 15.h,
                                  ),
                                ),
                              ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String phoneText = phoneNumber.text.trim();
                              String formattedPhone;

                              // إزالة أي مسافات أو رموز
                              phoneText = phoneText.replaceAll(
                                RegExp(r'[^\d]'),
                                '',
                              );

                              if (phoneText.startsWith('01')) {
                                // من 01xxxxxxxx إلى +201xxxxxxxx
                                formattedPhone = '+2$phoneText';
                              } else if (phoneText.startsWith('1')) {
                                // من 1xxxxxxx إلى +201xxxxxxx
                                formattedPhone = '+20$phoneText';
                              } else {
                                // إضافة +20 مباشرة
                                formattedPhone = '+20$phoneText';
                              }

                              print('Original phone: ${phoneNumber.text}');
                              print('Formatted phone: $formattedPhone');
                              context
                                  .read<PhoneSignUpCubit>()
                                  .submitPhoneNumber(formattedPhone);
                            }
                          },
                          child: Text("Next"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
