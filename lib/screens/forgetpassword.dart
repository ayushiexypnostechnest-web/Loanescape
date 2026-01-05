import 'package:flutter/material.dart';

import 'package:loan_app/screens/otp.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:loan_app/utils/local_otp_service.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: IgnorePointer(
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? "assets/images/v5_Dark.png"
                    : "assets/images/v6.png",
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: 0,
            child: IgnorePointer(
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? "assets/images/v6_dark.png"
                    : "assets/images/v5.png",
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Forget Password",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Don't worry! It happens. Please enter the email address associated with your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,

                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _label("Email ID"),
                  SizedBox(height: 13),
                  _inputField("Enter Your Email", controller: emailController),
                  SizedBox(height: 58),
                  Center(
                    child: SizedBox(
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
                          if (emailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter email"),
                              ),
                            );
                            return;
                          }

                          LocalOtpService.generateOtp(emailController.text);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const OtpScreen(),
                            ),
                          );
                        },

                        child: Text(
                          "Send Otp",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColors.black
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Remember Password"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lato',
        ),
      ),
    );
  }

  Widget _inputField(String hint, {required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppDarkColors.textfeild
              : Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(left: 15),
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: controller,

          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xff646464)
                  : Colors.black87,
              fontSize: 14,
              fontFamily: 'Lato',
            ),
          ),
        ),
      ),
    );
  }
}
