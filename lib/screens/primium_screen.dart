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
  int _selectedPlan = 0; // 0 = Yearly, 1 = Monthly

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;

    _currentPage = (_currentPage + 1) % 2;
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0F1014),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/premium_screen.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
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
                  SizedBox(height: 10),

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
                              Image.asset(
                                "assets/images/upgrade.png",
                                height: 14,
                              ),
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
                        Divider(
                          color: Color(0xff202225),
                          height: 1,
                          thickness: 1,
                        ),
                        SizedBox(height: 24),
                        const Text(
                          'Upgrade to unlock smarter loan insights',
                          style: TextStyle(
                            fontSize: 20,
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
                        const SizedBox(height: 24),
                        Divider(
                          color: Color(0xff202225),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: _planCard(
                                title: "Yearly",
                                price: "\$89.99",
                                subtitle:
                                    "one year access with a one time payment",
                                isSelected: _selectedPlan == 0,
                                onTap: () {
                                  setState(() => _selectedPlan = 0);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _planCard(
                                title: "Monthly",
                                price: "\$89.99",
                                subtitle: "Billed monthly",
                                isSelected: _selectedPlan == 1,
                                onTap: () {
                                  setState(() => _selectedPlan = 1);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 29),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Color(0xff2A63EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Start 7-Day Free Trial →",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 11),
                        Center(
                          child: Text(
                            "Auto renews yearly. Cancel Anytime.",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Color(0xff989898),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 21),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _footerLink("Terms of Use"),

                            _divider(),

                            _footerLink("Privacy Policy"),
                            _divider(),

                            _footerLink("Restore"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _footerLink(String text) {
  return GestureDetector(
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    ),
  );
}

Widget _divider() {
  return SizedBox(
    width: 24,
    height: 16,
    child: VerticalDivider(thickness: 1, color: Colors.white),
  );
}

Widget _planCard({
  required String title,
  required String price,
  required String subtitle,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: isSelected
            ? GradientBoxBorder(
                width: 1.6,
                gradient: SweepGradient(
                  center: Alignment.center,
                  colors: [
                    const Color(0xFF1F2D3A).withOpacity(0.70),
                    const Color(0xFF1F2D3A).withOpacity(0.70),
                    const Color(0xFFD7F2FF).withOpacity(0.70),
                    const Color(0xFFD7F2FF).withOpacity(0.70),
                    const Color(0xFF1F2D3A).withOpacity(0.70),
                    const Color(0xFFD7F2FF).withOpacity(0.70),
                    const Color(0xFFD7F2FF).withOpacity(0.70),
                    const Color(0xFFD7F2FF).withOpacity(0.70),

                    const Color(0xFFA8E3FF),
                  ],
                  stops: [0.03, 0.09, 0.17, 0.30, 0.52, 0.58, 0.80, 0.91, 1.0],
                ),
              )
            : GradientBoxBorder(
                width: 1.6,
                gradient: SweepGradient(
                  colors: [
                    const Color(0xFF1F2D3A).withOpacity(0.70),
                    const Color(0xFF1F2D3A).withOpacity(0.70),
                    const Color(0xFFD7F2FF).withOpacity(0.100),
                    const Color(0xFFD7F2FF).withOpacity(0.100),
                    const Color(0xFF1F2D3A).withOpacity(0.70),
                    const Color(0xFFD7F2FF).withOpacity(0.100),
                    const Color(0xFFD7F2FF).withOpacity(0.100),
                    const Color(0xFFD7F2FF).withOpacity(0.100),

                    const Color(0xFFA8E3FF),
                  ],
                  stops: [0.03, 0.09, 0.17, 0.30, 0.52, 0.58, 0.80, 0.91, 1.0],
                ),
              ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.black.withOpacity(0.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),

                if (isSelected)
                  Container(
                    height: 26,
                    width: 26,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2C75EA),
                    ),
                    child: Image.asset(
                      "assets/images/right.png",
                      height: 6,
                      width: 10,
                    ),
                  )
                else
                  Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
              ],
            ),

            Text(
              price,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFeaturePage2() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDE8FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "How Can I Reduce My Loan Interest Faster?",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: SvgPicture.asset(
                    height: 24,
                    width: 24,
                    "assets/images/user.svg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      "assets/images/awesome_dark.svg",
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "Based on your current loan, making one extra EMI every year can help you save ₹42,000 in interest and close the loan 11 months earlier.\n\nWould you like me to calculate the best month to do this?",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 10,
                    height: 1.55,
                    color: Colors.black,
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
          height: 22,
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
  double? height,
  double? width,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: SvgPicture.asset(icon, height: height ?? 16, width: width ?? 24),
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
          width: 1.2,
          gradient: SweepGradient(
            center: Alignment.center,
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
            stops: [0.0, 0.15, 0.3, 0.5, 0.65, 0.8, 0.9, 1.0],
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/glass.png"),
                fit: BoxFit.cover,
              ),

              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
