import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/data/onboarding_data.dart';
import 'package:loan_app/screens/sign_in.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      _goToSignIn();
    }
  }

  Future<void> _goToSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: kAlwaysDismissedAnimation,
            child: const SignIn(),
          );
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Positioned(
                            child: Image.asset(
                              isDark
                                  ? pages[index].imageDark
                                  : pages[index].imageLight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  if (_currentPage > 0)
                    Positioned(
                      top: 25,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.ease,
                          );
                        },
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF001230),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: TextButton(
                      onPressed: _goToSignIn,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SmoothPageIndicator(
              controller: _pageController,
              count: pages.length,
              effect: ExpandingDotsEffect(
                expansionFactor: 3,
                dotHeight: 8,
                dotWidth: 8,
                spacing: 6,
                activeDotColor: isDark
                    ? const Color(0xFF024ECE)
                    : AppColors.primary,
                dotColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 35),

            Column(
              key: ValueKey(_currentPage),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    pages[_currentPage].title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 66,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      pages[_currentPage].description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.white : const Color(0xff626262),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: 330,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _next,
                child: Text(
                  _currentPage == pages.length - 1 ? "Let’s Start" : "Continue",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.black
                        : AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
