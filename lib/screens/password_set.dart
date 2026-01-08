import 'package:flutter/material.dart';

import 'package:loan_app/screens/sign_in.dart';
import 'package:loan_app/theme/app_colors.dart';

class PasswordSet extends StatefulWidget {
  const PasswordSet({super.key});

  @override
  State<PasswordSet> createState() => _PasswordSetState();
}

class _PasswordSetState extends State<PasswordSet> {
  bool _isPasswordVisible = false;
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordcontroller = TextEditingController();

  bool _isStrongPassword(String password) {
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    return password.length >= 8 && hasNumber && hasSpecial;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            left: 0,
            top: 0,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/images/v5_Dark.png"
                  : "assets/images/v6.png",
            ),
          ),

          Positioned(
            left: 0,
            top: 0,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/images/v6_dark.png"
                  : "assets/images/v5.png",
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

          // SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),

                  Center(
                    child: Text(
                      "Create New Password",
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
                      "Your new password must be unique from those previously used. Please ensure it's secure.  ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _label("New Password"),
                  SizedBox(height: 13),
                  _inputField(
                    "*********",
                    controller: newPasswordcontroller,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),

                  _label("Confirm New Password"),
                  const SizedBox(height: 13),
                  _inputField(
                    "*********",
                    controller: passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      "Must be at least 8 characters. must contain 1 number\nmust contain 1 special character",
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black45,
                        fontSize: 10,
                      ),
                    ),
                  ),

                  const SizedBox(height: 38),

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
                          final newPassword = newPasswordcontroller.text.trim();
                          final confirmPassword = passwordController.text
                              .trim();

                          if (newPassword.isEmpty || confirmPassword.isEmpty) {
                            _showMessage("All fields are required");
                            return;
                          }

                          if (!_isStrongPassword(newPassword)) {
                            _showMessage(
                              "Password must be 8 characters long, contain a number & special character",
                            );
                            return;
                          }

                          if (newPassword != confirmPassword) {
                            _showMessage("Passwords do not match");
                            return;
                          }

                          _showMessage("Password updated successfully");

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => SignIn()),
                          );
                        },

                        child: Text(
                          "Update Password",
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
          fontFamily: 'Lato',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // TEXT FIELD
  Widget _inputField(
    String hint, {
    required TextEditingController controller,
    bool obscure = false,
    bool isPassword = false,
  }) {
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

          obscureText: isPassword ? !_isPasswordVisible : obscure,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Lato',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xff646464)
                  : Colors.black54,
              fontSize: 14,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,

                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
