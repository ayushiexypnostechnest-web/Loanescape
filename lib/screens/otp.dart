import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_app/screens/password_set.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:loan_app/utils/local_otp_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? _timer;
  int _seconds = 120;
  bool _canResend = false;

  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _seconds = 120;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Widget _otpBox(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      width: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? isDark
                    ? Colors.white
                    : Colors.black26
              : (isDark ? const Color(0xff414141) : Colors.black26),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        cursorHeight: 28,
        cursorColor: isDark ? Colors.white : Colors.black,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < _controllers.length - 1) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
          setState(() {});
        },
        onTap: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
      body: Stack(
        children: [
          Positioned(
            left: 60,
            top: 1,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/images/v3_dark.png"
                  : "assets/images/v4.png",
            ),
          ),

          Positioned(
            left: 40,
            top: 0,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/images/v4_dark.png"
                  : "assets/images/v3.png",
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF001230),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                Text(
                  "Verify Email Address",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.white
                          : Colors.black54,
                    ),
                    children: [
                      const TextSpan(text: "verify code sent to "),
                      TextSpan(
                        text: LocalOtpService.email ?? "",
                        style: const TextStyle(
                          color: Color(0xff2F80ED),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _otpBox(index),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _canResend
                      ? () {
                          LocalOtpService.resendOtp();
                          _startTimer();
                        }
                      : null,
                  child: Text(
                    _canResend
                        ? "Resend Confirmation Code"
                        : "${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')} Resend Confirmation Code",
                    style: TextStyle(
                      fontSize: 13,
                      color: _canResend
                          ? const Color(0xff2F80ED)
                          : (Theme.of(context).brightness == Brightness.dark
                                ? AppDarkColors.white
                                : AppColors.black),
                      fontFamily: 'Lato',
                      fontWeight: _canResend
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: 335,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.white
                          : AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      String otp = _controllers.map((e) => e.text).join();
                      if (otp.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Enter valid OTP"),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      final result = LocalOtpService.verifyOtp(otp);

                      if (result == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PasswordSet()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },

                    child: Text(
                      "Confirm Code",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.black
                            : AppColors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
