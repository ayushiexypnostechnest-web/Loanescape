import 'dart:math';

class LocalOtpService {
  static String? _otp;
  static String? _email;

  static String generateOtp(String email) {
    _email = email;
    _otp = (1000 + Random().nextInt(9000)).toString();
    print("📩 OTP sent to $email : $_otp");
    return _otp!;
  }

  static bool verifyOtp(String enteredOtp) {
    return enteredOtp == _otp;
  }

  static String? get email => _email;

  static void clear() {
    _otp = null;
    _email = null;
  }
}
