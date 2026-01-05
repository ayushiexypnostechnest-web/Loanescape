import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class PrimiumScreen extends StatefulWidget {
  const PrimiumScreen({super.key});

  @override
  State<PrimiumScreen> createState() => _PrimiumScreenState();
}

class _PrimiumScreenState extends State<PrimiumScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Auto scroll
    Future.delayed(const Duration(seconds: 2), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;

    _currentPage = (_currentPage + 1) % 2;
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/premium_screen.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Content padding starts here
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xffFFFBEB),
                        borderRadius: BorderRadius.circular(34),
                        border: GradientBoxBorder(
                          width: 1,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFE7D0F), Color(0xFFFDB22B)],
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/images/upgrade.png", height: 14),
                          const SizedBox(width: 6),
                          const Text(
                            "PRO MEMBER",
                            style: TextStyle(
                              fontSize: 8,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              color: Color(0xffFFB539),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Unlock Unlimited',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const Text(
                      'Access today',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        color: Color(0xff2A63EB),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    const Text(
                      'Master Your Debt With AI-driven Insights And Exclusive Premium Tools.',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Lato',
                        color: Color(0xff989898),
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(color: Color(0xff202225), height: 1, thickness: 1),
                    SizedBox(height: 24),
                    const Text(
                      'Upgrade to unlock smarter loan insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        color: Color(0xffDDDFEA),
                      ),
                    ),
                    SizedBox(height: 23),
                    Center(
                      child: GlassContainer(
                        height: 265,
                        width: double.infinity,
                        child: SizedBox(
                          height: 265,
                          child: PageView(
                            controller: _pageController,
                            children: [
                              _buildFeaturePage1(),
                              _buildFeaturePage2(),
                            ],
                          ),
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
    );
  }
}

Widget _buildFeaturePage2() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDDE8FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              "How Can I Reduce My Loan Interest Faster?",
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// AI Reply Bubble + Icon
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// AI Icon (Your awesome icon)
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: ClipOval(
                child: SvgPicture.asset(
                  "assets/images/awesome.svg",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 10),

            /// AI Bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Based on your current loan, making one extra EMI every year can help you save ₹42,000 in interest and close the loan 11 months earlier.\n\nWould you like me to calculate the best month to do this?",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFeaturePage1() {
  return Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _featureRow(
          icon: "assets/images/p1.svg",
          title: "Smart loan optimization",
          desc:
              "Get AI-powered suggestions to repay loans faster and save interest.",
        ),
        const SizedBox(height: 18),

        _featureRow(
          icon: "assets/images/p2.svg",
          title: "Ad-Free Experience",
          desc: "Enjoy a clean, distraction-free app with zero advertisements.",
        ),
        const SizedBox(height: 18),

        _featureRow(
          icon: "assets/images/p3.svg",
          title: "Unlimited Ask AI Access",
          desc:
              "Ask unlimited questions and get personalized advice for each loan.",
        ),
      ],
    ),
  );
}

Widget _featureRow({
  required String icon,
  required String title,
  required String desc,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: SvgPicture.asset(icon, height: 16, width: 24),
      ),
      const SizedBox(width: 20),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 11,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;

  const GlassContainer({
    super.key,
    required this.child,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: GradientBoxBorder(
          width: 1,
          gradient: SweepGradient(
            colors: [
              const Color(0xFF1F2D3A).withOpacity(0.70),
              const Color(0xFF1F2D3A).withOpacity(0.70),
              const Color(0xFFA8E3FF),
              const Color(0xFFA8E3FF),
              const Color(0xFF1F2D3A).withOpacity(0.70),
              const Color(0xFFA8E3FF),
              const Color(0xFFA8E3FF),
              const Color(0xFFA8E3FF),
            ],
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(),
            ),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xff2A63EB).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff0F1014),
                    Colors.transparent,
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),

            Center(child: child),
          ],
        ),
      ),
    );
  }
}
