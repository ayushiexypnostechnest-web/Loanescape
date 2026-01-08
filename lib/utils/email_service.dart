import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static Future<void> sendOtp(String email, String otp) async {
    const serviceId = "service_abxsjrq";
    const templateId = "template_34ct9bi";
    const publicKey = "A4u9NLi3GmTFMIL0Q";

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "origin": "http://localhost",
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {"to_email": email, "otp": otp},
      }),
    );
  }
}
