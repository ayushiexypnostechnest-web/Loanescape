import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpData {
  final String otp;
  final DateTime expiresAt;
  int attempts;

  OtpData(this.otp, this.expiresAt, this.attempts);
}

class LocalOtpService {
  static final Map<String, OtpData> _store = {};
  static String? _email;

  // Generate new OTP
  static String generateOtp(String email) {
    _email = email;

    final otp = (1000 + Random().nextInt(9000)).toString();

    _store[email] = OtpData(
      otp,
      DateTime.now().add(const Duration(minutes: 2)), // 2 minutes expiry
      0,
    );

    return otp;
  }

  // Verify OTP
  static String? verifyOtp(String enteredOtp) {
    final data = _store[_email];

    if (data == null) return "OTP expired";

    if (DateTime.now().isAfter(data.expiresAt)) {
      _store.remove(_email);
      return "OTP expired";
    }

    data.attempts++;

    if (data.attempts > 5) {
      _store.remove(_email);
      return "Too many attempts. OTP locked.";
    }

    if (enteredOtp != data.otp) return "Invalid OTP";

    _store.remove(_email);
    return null;
  }

  // 🔁 Resend OTP
  static Future<void> resendOtp() async {
    if (_email == null) return;

    final newOtp = generateOtp(_email!);
    await sendOtpToEmail(_email!, newOtp);
  }

  // ✉ Send OTP via EmailJS
  static Future<void> sendOtpToEmail(String email, String otp) async {
    const serviceId = "service_abxsjrq";
    const templateId = "template_34ct9bi";
    const publicKey = "A4u9NLi3GmTFMIL0Q";

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {
          "to_email": email,
          "otp": otp,
          "from_name": "LoanEscape",
        },
      }),
    );

    if (response.statusCode == 200) {
      print("OTP sent to $email successfully: $otp");
    } else {
      print("Failed to send OTP: ${response.body}");
    }
  }

  static String? get email => _email;
}
