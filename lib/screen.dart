import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool isYearlySelected = true;
  late Timer _timer;
  late final List<Map<String, String>> loopSlides;

  @override
  void initState() {
    super.initState();

    loopSlides = [...slides, slides.first];

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> features = [
    {
      "icon": "assets/images/icon1.svg",
      "title": "Al Meal Scanner",
      "subtitle": "Scan meals with AI accuracy",
    },
    {
      "icon": "assets/images/icon2.svg",
      "title": "Smart Insights",
      "subtitle": "Clear insights, no confusion",
    },
    {
      "icon": "assets/images/icon3.svg",
      "title": "Nutrition Targets",
      "subtitle": "Track goals that fit your body",
    },
    {
      "icon": "assets/images/icon4.svg",
      "title": "Instant Calories",
      "subtitle": "Calories at a glance",
    },
  ];

  final List<Map<String, String>> slides = [
    {
      "image": "assets/images/plate.png",
      "title": "What’s Really in This Meal?",
      "subtitle": "Not sure if this meal fits your goals?",
    },
    {
      "image": "assets/images/plate1.png",
      "title": "Track Your Nutrition",
      "subtitle": "Get instant AI-based food analysis",
    },
    {
      "image": "assets/images/plate2.png",
      "title": "Eat Smarter",
      "subtitle": "Personalized health recommendations",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/screen.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(child: SvgPicture.asset("assets/images/v.svg")),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Restore",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/images/v1.svg'),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _gradientText('Get', 15, FontWeight.w400),
                          _gradientText('Premium', 15, FontWeight.w400),
                        ],
                      ),
                      const SizedBox(width: 10),
                      SvgPicture.asset('assets/images/v2.svg'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _gradientText(
                    'Unlock AI-Powered Nutrition',
                    22,
                    FontWeight.w700,
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 330,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: loopSlides.length,
                      onPageChanged: (index) {
                        if (index == loopSlides.length - 1) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _pageController.jumpToPage(0);
                          });
                        }
                        setState(() {
                          _currentIndex = index % slides.length;
                        });
                      },
                      itemBuilder: (context, index) {
                        final slide = loopSlides[index];
                        return Column(
                          children: [
                            SizedBox(
                              height: _currentIndex == 2 ? 234 : 230,
                              width: _currentIndex == 2 ? 334 : 230,
                              child: Image.asset(
                                slide['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 17),
                            Text(
                              slide['title']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slide['subtitle']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  SmoothPageIndicator(
                    controller: _pageController,
                    count: slides.length,
                    effect: ExpandingDotsEffect(
                      expansionFactor: 3,
                      dotHeight: 6,
                      dotWidth: 8,
                      spacing: 5,
                      activeDotColor: const Color(0xFFBD8436),
                      dotColor: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  SizedBox(height: 39),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black, Color(0xFFAEAEAE)],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        "Pro Features",
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF1C771),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFAEAEAE), Colors.black],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: features.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.4,
                        ),
                    itemBuilder: (context, index) {
                      final item = features[index];

                      return bigGlassCard(
                        iconPath: item["icon"]!,
                        title: item["title"]!,
                        subtitle: item["subtitle"]!,
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xffBD8436), Color(0xFFF1C771)],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: SvgPicture.asset(
                          "assets/images/D.svg",
                          height: 8,
                          width: 8,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Image.asset("assets/images/D.png", height: 11, width: 19),

                      const SizedBox(width: 10),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: SvgPicture.asset(
                          "assets/images/D.svg",
                          height: 8,
                          width: 8,
                        ),
                      ),

                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xffBD8436), Color(0xFFF1C771)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  Row(
                    children: [
                      Expanded(
                        child: subscriptionCard(
                          isSelected: isYearlySelected,
                          title: "Yearly",
                          price: "\$00.00",
                          subtitle: "Billed annually",
                          showBadge: true,
                          badgeText: "Best Value",
                          discountText: "-50%",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: subscriptionCard(
                          isSelected: !isYearlySelected,
                          title: "Monthly",
                          price: "\$00.00",
                          subtitle: "Billed monthly",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffBD8436), Color(0xFFF1C771)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Unlock Premium",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Terms & Conditions",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
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

  Widget subscriptionCard({
    required bool isSelected,
    required String title,
    required String price,
    required String subtitle,
    bool showBadge = false,
    String? badgeText,
    String? discountText,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isYearlySelected = title == "Yearly";
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xffBD8436), Color(0xFFF1C771)],
                    )
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                left: 18,
                top: 25,
                right: 18,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff1B1B1B), Color(0xff0E0E0E)],
                ),
                border: isSelected
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      Container(
                        height: 26,
                        width: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: isSelected
                                ? const Color(0xffF1C771)
                                : Colors.white54,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffF1C771),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (discountText != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff2A2115),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            discountText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xffF1C771),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),

          if (showBadge)
            Positioned(
              top: -14,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffBD8436), Color(0xFFF1C771)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  badgeText ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gradientText(String text, double fontSize, FontWeight fontWeight) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [Color(0xFFBD8436), Color(0xFFF1C771)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: GoogleFonts.merriweather(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }
}

Widget bigGlassCard({
  required String iconPath,
  required String title,
  required String subtitle,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
          border: GradientBoxBorder(
            width: 1,
            gradient: SweepGradient(
              colors: [
                const Color(0xFF404040).withOpacity(0.50),
                const Color(0xFF404040).withOpacity(0.35),
                const Color(0xFFFFFFFF).withOpacity(0.30),
                const Color(0xFFFFFFFF).withOpacity(0.30),
                const Color(0xFF404040).withOpacity(0.35),
                const Color(0xFFF9F9F9).withOpacity(0.50),
                const Color(0xFFFFFFFF).withOpacity(0.30),
                const Color(0xFFF9F9F9).withOpacity(0.30),
              ],
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, child: smallGlassIconBox(iconPath)),

            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget smallGlassIconBox(String iconPath) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: GradientBoxBorder(
            width: 1,
            gradient: SweepGradient(
              colors: [
                const Color(0xFF404040).withOpacity(0.50),
                const Color(0xFF404040).withOpacity(0.35),
                const Color(0xFFFFFFFF).withOpacity(0.30),
                const Color(0xFFFFFFFF).withOpacity(0.30),
                const Color(0xFF404040).withOpacity(0.35),
                const Color(0xFFF9F9F9).withOpacity(0.50),
                const Color(0xFFFFFFFF).withOpacity(0.30),
                const Color(0xFFF9F9F9).withOpacity(0.30),
              ],
            ),
          ),
        ),
        child: Center(child: SvgPicture.asset(iconPath, height: 24, width: 24)),
      ),
    ),
  );
}
