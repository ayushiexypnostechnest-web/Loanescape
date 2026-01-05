import 'package:flutter/material.dart';
import 'package:loan_app/screens/dashboard/Bottombar.dart';

import 'package:loan_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool agree = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  //Shared Prefrence
  Future<void> _saveData() async {
    if (_validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("name", nameController.text);
      await prefs.setString("email", emailController.text);
      await prefs.setString("password", passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Account Created Sucessfully",
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => const DashboardBottomBar()),
      );
    }
  }

  //FORM VALIDATION
  bool _validate() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      _showError("Please enter your name");
      return false;
    }

    if (email.isEmpty) {
      _showError("Please enter your email");
      return false;
    }
    if (confirmPasswordController.text.trim().isEmpty) {
      _showError("Please confirm your password");
      return false;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showError("Passwords do not match");
      return false;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError("Please enter a valid email");
      return false;
    }

    if (password.isEmpty) {
      _showError("Please enter your password");
      return false;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return false;
    }

    if (!agree) {
      _showError("Please agree to Terms & Conditions");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating, // makes it floating
        backgroundColor: isDark ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // rounded corners
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ), // margin from screen edges
        duration: const Duration(seconds: 2), // how long it stays
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/images/v1_dark.png"
                  : "assets/images/v2.png",
            ),
          ),

          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/images/v2_dark.png"
                  : "assets/images/v1.png",
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),

                  Center(
                    child: Text(
                      "Let’s Create Account",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      "With SmartLoan, tracking your EMIs is easier than ever before and keeps you in full control.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        height: 1.5,

                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _label("Name"),
                  SizedBox(height: 13),
                  _inputField(
                    "Enter Your Name",
                    controller: nameController,
                    focusNode: nameFocus,
                    nextFocus: emailFocus,
                  ),

                  const SizedBox(height: 20),

                  _label("Email"),
                  SizedBox(height: 13),
                  _inputField(
                    "Enter Your Email",
                    controller: emailController,
                    focusNode: emailFocus,
                    nextFocus: passwordFocus,
                  ),

                  const SizedBox(height: 20),
                  _label("Password"),

                  SizedBox(height: 13),
                  _inputField(
                    "*********",
                    controller: passwordController,
                    isPassword: true,
                    focusNode: passwordFocus,
                    nextFocus: confirmPasswordFocus,
                  ),
                  const SizedBox(height: 20),

                  _label("Confirm Password"),
                  SizedBox(height: 13),
                  _inputField(
                    "*********",
                    controller: confirmPasswordController,
                    isPassword: true,
                    focusNode: confirmPasswordFocus,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => agree = !agree);
                          },
                          child: Container(
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black),
                              color: agree ? Color(0xff001230) : Colors.white,
                            ),
                            child: agree
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Agree With",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Terms & Condition",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppDarkColors.white
                                  : AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

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
                        onPressed: _saveData,

                        child: Text(
                          "Sign Up",
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
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "or sign up with",
                            style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(context, "assets/images/google.png"),
                      const SizedBox(width: 25),
                      _socialIcon(context, "assets/images/apple.png"),
                      const SizedBox(width: 25),
                      _socialIcon(context, "assets/images/facebook.png"),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LABEL
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

  // TEXT FIELD
  Widget _inputField(
    String hint, {
    required TextEditingController controller,
    bool obscure = false,
    bool isPassword = false,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputAction? textInputAction,
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
          focusNode: focusNode,
          textInputAction: textInputAction ?? TextInputAction.next,
          onEditingComplete: () {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              FocusScope.of(context).unfocus(); // last field
            }
          },
          cursorColor: Theme.of(context).brightness == Brightness.dark
              ? AppDarkColors.white
              : Colors.black,
          controller: controller,
          obscureText: isPassword ? !_isPasswordVisible : obscure,
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

  // SOCIAL ICON BUTTON
  Widget _socialIcon(BuildContext context, String path) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = path.contains("apple");

    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isDark ? const Color(0xFFC7C7C7) : Colors.black26,
        ),
      ),
      child: Center(
        child: Image.asset(
          path,
          height: 24,
          color: (isDark && isApple) ? Colors.white : null,
        ),
      ),
    );
  }
}
