import 'package:flutter/material.dart';
import 'package:loan_app/screens/dashboard/Bottombar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loan_app/screens/sign_in.dart';
import 'package:loan_app/services/google_signin.dart';

import 'package:loan_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;
  bool _isPasswordVisible = false;
  bool agree = false;
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  //FOR GOOGLESIGNIN
  Future<void> _handleGoogleLogin() async {
    final user = await GoogleSignin.login();

    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", user.displayName ?? "");
    await prefs.setString("email", user.email);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardBottomBar()),
    );
  }

  //Shared Prefrence
  Future<void> _saveData() async {
    if (_validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("name", nameController.text);
      await prefs.setString("email", emailController.text);
      await prefs.setString("password", passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Account Created Sucessfully",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.white
                  : AppColors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppDarkColors.primary
              : AppColors.primary,
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
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _termsError = null;
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _nameError = "Name is required";
    }

    if (email.isEmpty) {
      _emailError = "Email is required";
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _emailError = "Enter a valid email";
    }

    if (password.isEmpty) {
      _passwordError = "Password is required";
    } else if (password.length < 6) {
      _passwordError = "Password must be at least 6 characters";
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = "Confirm your password";
    } else if (password != confirmPassword) {
      _confirmPasswordError = "Passwords do not match";
    }

    if (!agree) {
      _termsError = "Please accept Terms & Conditions";
    }

    setState(() {});
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _termsError == null;
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
              padding: const EdgeInsets.only(bottom: 100),
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
                    errorText: _nameError,
                    controller: nameController,
                    focusNode: nameFocus,
                    nextFocus: emailFocus,
                  ),

                  const SizedBox(height: 20),

                  _label("Email"),
                  SizedBox(height: 13),
                  _inputField(
                    "Enter Your Email",
                    errorText: _emailError,
                    controller: emailController,
                    focusNode: emailFocus,
                    nextFocus: passwordFocus,
                  ),

                  const SizedBox(height: 20),
                  _label("Password"),

                  SizedBox(height: 13),
                  _inputField(
                    "Please Enter Password",
                    errorText: _passwordError,
                    controller: passwordController,
                    isPassword: true,
                    focusNode: passwordFocus,
                    nextFocus: confirmPasswordFocus,
                  ),
                  const SizedBox(height: 20),

                  _label("Confirm Password"),
                  SizedBox(height: 13),
                  _inputField(
                    "Please Confirm Password",
                    errorText: _confirmPasswordError,
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
                              border: Border.all(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              color: agree
                                  ? (isDark
                                        ? Colors.white
                                        : const Color(0xff001230))
                                  : (isDark
                                        ? Colors.transparent
                                        : Colors.white),
                            ),
                            child: agree
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: isDark ? Colors.black : Colors.white,
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
                  if (_termsError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        _termsError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
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
                      const SizedBox(width: 20),
                      _socialIcon(context, "assets/images/apple.png"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don’t have an account? ",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppDarkColors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              MaterialPageRoute(builder: (ctx) => SignIn()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppDarkColors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    String? errorText,
    FocusNode? nextFocus,
    TextInputAction? textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.textfeild
                  : Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(10),
              border: errorText != null
                  ? Border.all(color: Colors.red, width: 1)
                  : null,
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
                  FocusScope.of(context).unfocus();
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
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 6),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _socialIcon(BuildContext context, String path) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = path.contains("apple");

    return GestureDetector(
      onTap: () {
        if (path.contains("google")) {
          _handleGoogleLogin();
        }
      },
      child: Container(
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
      ),
    );
  }
}
