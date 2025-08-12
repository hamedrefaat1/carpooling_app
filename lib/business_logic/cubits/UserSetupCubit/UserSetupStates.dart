abstract class UserSetupStates {}

class UserSetupIntial extends UserSetupStates {}

class UserSetupLoading extends UserSetupStates {}

class UserSetupSuccessed extends UserSetupStates {}

class UserSetupError extends UserSetupStates {
  String error;
  UserSetupError(this.error);
}
