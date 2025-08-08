import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class Signup extends StatelessWidget {
   Signup({super.key});

   FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: Scaffold(
          body: Container(
            margin: EdgeInsets.only(top: 100.h, right: 15.w , left: 15.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to the Carpooling App",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 22.sp, // بدل من headlineLarge
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Please enter your phone number to verfiy your account",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                    
                      child:TextFormField(
                        keyboardType: TextInputType.number,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        
                          hintText: "Enter your phone",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface
                            )
                          ),
                          focusedBorder:OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue
                            )
                          ),
                      ),
                      validator: (value){
                         if(value == null || value.isEmpty){
                      return "Please enter your number";
                         }
                         if(value.length <11){
                          return "enter a valid number";
                         }
                         return null;
                      },
                    )) 
                    ],
                  ),
                         
                Gap(40.h),
                Center(
                  child: ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                       padding: WidgetStateProperty.all( EdgeInsets.symmetric(horizontal: 70.w, vertical: 15.h)),
                    ),
                    onPressed: (){
                  
                  }, child: Text("Next")),
                )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
