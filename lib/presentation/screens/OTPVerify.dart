import 'package:carpooling_app/business_logic/cubits/AuthCubit/cubit_auth.dart';
import 'package:carpooling_app/business_logic/cubits/AuthCubit/state_auth.dart';
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class VerifyPhoneScreen extends StatelessWidget {
  final String phoneNumber;

  const VerifyPhoneScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final otpControllers = List.generate(6, (_) => TextEditingController());
    final otpFocusNodes = List.generate(6, (_) => FocusNode());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(80.h),
            Text(
              "Verify your phone number",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
           
             SizedBox(height: 40.h),
            Text(
              "Enter the 6-digit code sent to your phone",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          Gap(10),
             Text(
              phoneNumber,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                  ),
            ),
             SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45.w,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: Theme.of(context).textTheme.titleLarge,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context)
                            .requestFocus(otpFocusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context)
                            .requestFocus(otpFocusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),
             SizedBox(height: 30.h),
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
                        } else if (state is OtpVerified ) {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/homeScreen',
                          );
                        }
                      },
                      child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String otpCode =
                        otpControllers.map((c) => c.text).join();
                    if(otpCode.length>5){
                       context.read<PhoneSignUpCubit>().submitCode(otpCode);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Verify",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
             SizedBox(height: 20.h),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Resend Code",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
