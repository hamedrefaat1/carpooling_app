
abstract class PhoneSignup {}

class PhoneSignupInitial extends PhoneSignup{}

class PhoneSignupLoading extends PhoneSignup{}

class PhoneNumberSubmitted extends PhoneSignup{}

class OtpVerified  extends PhoneSignup{}

class PhoneSignupError extends PhoneSignup{
  String error ;
  PhoneSignupError(this.error);
}