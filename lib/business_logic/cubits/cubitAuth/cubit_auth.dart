import 'package:carpooling_app/business_logic/cubits/cubitAuth/state_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneSignUpCubit extends Cubit<PhoneSignup> {
  PhoneSignUpCubit() : super(PhoneSignupInitial());
  String? _verificationId;
  Future<void> submitPhoneNumber(String phoneNumber) async {
    emit(PhoneSignupLoading());

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 15),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        emit(OtpVerified());
      },
      verificationFailed: (FirebaseAuthException exption) {
        emit(PhoneSignupError(exption.toString()));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        emit(PhoneNumberSubmitted());
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> submitCode(String otpCode) async {
    emit(PhoneSignupLoading());
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(OtpVerified());
    } catch (e) {
      emit(PhoneSignupError(e.toString()));
    }
  }
}
