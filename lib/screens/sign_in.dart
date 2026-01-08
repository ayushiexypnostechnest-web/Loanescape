import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:loan_app/screens/dashboard/Bottombar.dart';
import 'package:loan_app/screens/forgetpassword.dart';
import 'package:loan_app/screens/sign_up.dart';
import 'package:loan_app/services/google_signin.dart';
import 'package:loan_app/services/user_local_storage.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String? _emailError;
  String? _passwordError;

  bool _isPasswordVisible = false;
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _handleGoogleLogin() async {
    final user = await GoogleSignin.login();
    if (user == null) return;

    final supabase = Supabase.instance.client;

    final existingUser = await supabase
        .from('users')
        .select()
        .eq('email', user.email)
        .maybeSingle();

    if (existingUser == null) {
      await supabase.from('users').insert({
        'name': user.displayName ?? 'No Name',
        'email': user.email,
        'password': '',
      });
    }

    await UserLocalStorage.saveUser(
      name: user.displayName ?? 'No Name',
      email: user.email,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardBottomBar()),
    );
  }

  void _signIn() async {
    if (!_validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final supabase = Supabase.instance.client;

      // Fetch the user with this email
      final user = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not found")));
        return;
      }

      if (user['password'] != password) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Incorrect password")));
        return;
      }

      await UserLocalStorage.saveUser(name: user['name'], email: user['email']);
       final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);


      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardBottomBar()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  bool _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

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

    setState(() {});
    return _emailError == null && _passwordError == null;
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

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  Center(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      "Sign in to access your loans and track EMIs securely in one place.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

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
                  const SizedBox(height: 13),
                  _inputField(
                    "*********",
                    controller: passwordController,
                    isPassword: true,
                    errorText: _passwordError,
                    focusNode: passwordFocus,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => Forgetpassword(),
                            ),
                          );
                        },
                        child: Text(
                          "Forget Password?",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppDarkColors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
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
                        onPressed: _signIn,
                        child: Text(
                          "Sign In",
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
                          child: Text(
                            "Or",
                            style: TextStyle(fontFamily: 'Lato'),
                          ),
                        ),
                        Expanded(child: Divider()),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => SignUpScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Sign Up",
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _inputField(
    String hint, {
    required TextEditingController controller,
    bool obscure = false,
    bool isPassword = false,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    String? errorText,

    TextInputAction? textInputAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            alignment: Alignment.center,
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
              controller: controller,
              cursorColor: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.white
                  : Colors.black,
              obscureText: isPassword ? !_isPasswordVisible : obscure,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Lato',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xff646464)
                      : Colors.black87,
                  fontSize: 14,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: isDark ? Colors.white : Colors.black,
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
