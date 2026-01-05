import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:loan_app/models/loan_model.dart';
import 'package:loan_app/screens/AI/geminichatboat.dart';
import 'package:loan_app/screens/Loan_Detail/whatif_screen.dart';
import 'package:loan_app/theme/app_colors.dart';

class FloatingAiButtons extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onWhatIfTap;
  final VoidCallback onAiTap;

  const FloatingAiButtons({
    super.key,
    required this.onWhatIfTap,
    required this.onAiTap,
    required this.loan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _pillButton(
            context,
            title: "What If?",
            subtitle: "Scenarios",
            icon: 'assets/images/whatif.svg',
            page: WhatifScreen(),
          ),
        ),
        const SizedBox(height: 13),
        _pillButton(
          context,
          title: "AI Assistant",
          subtitle: "For This Loan",
          icon: 'assets/images/ai_assistance.svg',
          page: Geminichatboat(loan: loan),
        ),
      ],
    );
  }

  Widget _pillButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Widget page,
  }) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(milliseconds: 400),
      closedElevation: 0,
      openElevation: 4,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      openColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : Colors.white,

      closedColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.primary
          : AppColors.primary,

      closedBuilder: (context, openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: Container(
            height: 56,
            padding: const EdgeInsets.only(left: 14, right: 7),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.primary
                  : AppColors.primary,

              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.black
                            : AppColors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 10,
                        height: 1.1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF656565)
                            : const Color(0xFFADB5BD),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                gradientIconCircle(icon, context),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, _) {
        return page;
      },
    );
  }

  Widget gradientIconCircle(String icon, BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: GradientBoxBorder(
          width: 1,
          gradient: SweepGradient(
            colors: [
              Color(0xFF404040).withOpacity(0.50),
              Color(0xFF404040).withOpacity(0.35),
              Color(0xFFFFFFFF).withOpacity(0.50),
              Color(0xFFFFFFFF).withOpacity(0.50),
              Color(0xFF404040).withOpacity(0.35),
              Color(0xFFF9F9F9),
              Color(0xFFFFFFFF).withOpacity(0.5),
              Color(0xFFF9F9F9).withOpacity(0.50),
            ],
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppDarkColors.circle.withOpacity(0.10)
              : const Color(0xFF1E293B),
        ),
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.black
              : AppColors.white,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
