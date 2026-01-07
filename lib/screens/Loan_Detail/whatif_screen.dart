import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loan_app/theme/app_colors.dart'; // Assuming your theme file

class WhatifScreen extends StatefulWidget {
  const WhatifScreen({super.key});

  @override
  State<WhatifScreen> createState() => _WhatifScreenState();
}

class _WhatifScreenState extends State<WhatifScreen> {
  final ScrollController _controller = ScrollController();
  final Map<String, bool> _expandedState = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.scaffold : AppColors.scaffold,
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            expandedHeight: 180.0,

            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.scaffold.withOpacity(0.5)
                : AppColors.scaffold.withOpacity(0.5),
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppDarkColors.scaffold.withOpacity(0.5)
                        : AppColors.scaffold.withOpacity(0.5),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final topPadding = MediaQuery.of(context).padding.top;
                        final isCollapsed =
                            constraints.maxHeight <=
                            kToolbarHeight + topPadding;

                        return Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                isCollapsed ? topPadding + 18 : 12,
                                16,
                                0,
                              ),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 18,
                                      color: isDark
                                          ? AppDarkColors.primary
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Loan Information",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppDarkColors.textPrimary
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (!isCollapsed)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  50,
                                  20,
                                  20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "What If",
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Lato',
                                        color: isDark
                                            ? AppDarkColors.textPrimary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Explore Scenarios",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppDarkColors.primary
                                            : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Understand how different actions impact your loan",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFF919AA7)
                                            : const Color(0xFF545E6D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Centered title when collapsed
                            if (isCollapsed)
                              Center(
                                child: Text(
                                  "What If",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lato',
                                    color: isDark
                                        ? AppDarkColors.textPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content with proper bottom padding
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ..._buildWhatIfCards(),
                const SizedBox(
                  height: 40,
                ), // Extra bottom padding to prevent overflow
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWhatIfCards() {
    final cards = [
      _whatIfCard(
        icon: "assets/images/i5.svg",
        title: "What if I skip EMI for 3 months?",
        details: const [
          "You must contact your lender and submit a formal request",
          "Approval depends on valid reasons like job loss or medical emergency",
          "Interest usually continues to accrue during the pause",
          "Your total loan cost or future EMI may increase",
        ],
      ),
      _whatIfCard(
        icon: "assets/images/i6.svg",
        title: "What if I pay EMI after the due date?",
        details: const [
          "You can pay via lender app, UPI, net banking, or branch visit",
          "Late fees and penal interest will be charged",
          "Delay may negatively impact your credit score",
          "Contacting your lender early may reduce penalties",
        ],
      ),
      _whatIfCard(
        icon: "assets/images/i7.svg",
        title: "What if interest rate increases by 1%?",
        details: const [
          "Your monthly EMI will increase",
          "If EMI stays same, loan tenure will extend",
          "You will pay significantly more interest overall",
        ],
      ),
      _whatIfCard(
        icon: "assets/images/i8.svg",
        title: "What if I miss my next 2 EMIs?",
        details: const [
          "Late fees and penal interest will be added",
          "Credit score may drop significantly (80–120 points)",
          "Lender may start frequent recovery calls",
          "Loan tenure and total interest will increase",
        ],
      ),
      _whatIfCard(
        icon: "assets/images/i5.svg",
        title: "What if I make an extra payment?",
        details: const [
          "You can choose to reduce tenure or EMI",
          "Reducing tenure saves the most interest",
          "Extra payments directly reduce principal",
        ],
      ),
      _whatIfCard(
        icon: "assets/images/i7.svg",
        title: "What if I pause my loan temporarily?",
        details: const [
          "You may request moratorium or deferment",
          "Interest usually continues during the pause",
          "Approval depends on lender and loan type",
          "Future EMI or loan tenure may increase",
        ],
      ),
    ];

    return cards;
  }

  Widget _whatIfCard({
    required String icon,
    required String title,
    List<String>? details,
  }) {
    final bool isExpanded = _expandedState[title] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.textfeild
            : const Color(0xFFE9ECEF),

        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRect(
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            dense: true,
            // visualDensity: const VisualDensity(vertical: -3),
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedState[title] = expanded;
              });
            },
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 2,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),

            trailing: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xff6B7280),
              ),
            ),

            title: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xff959CA9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: SvgPicture.asset(icon)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppDarkColors.white
                                : AppColors.primary,
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: isExpanded ? 0 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: const Text(
                            "Tap to view more",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xff6B7280),
                              fontFamily: 'Lato',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            children: details == null
                ? []
                : details
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
          ),
        ),
      ),
    );
  }
}
