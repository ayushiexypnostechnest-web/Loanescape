import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loan_app/models/loan_model.dart';
import 'package:loan_app/providers/currency_provider.dart';

import 'package:loan_app/screens/Loan_Detail/loan_detail.dart';
import 'package:loan_app/theme/app_colors.dart';

import 'package:loan_app/utils/loan_calculator.dart';
import 'package:provider/provider.dart';

class ActiveLoanCard extends StatelessWidget {
  final Map<String, dynamic> loan;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActiveLoanCard({
    super.key,
    required this.loan,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  String getLoanIconPath(String? type) {
    switch (type) {
      case "Home Loan":
        return "assets/images/Home.svg";
      case "Car Loan":
        return "assets/images/car.svg";
      case "Personal Loan":
        return "assets/images/personal.svg";
      case "Education Loan":
        return "assets/images/education.svg";
      case "Business Loan":
        return "assets/images/business.svg";
      case "Gold Loan":
        return "assets/images/gold.svg";
      default:
        return "assets/images/other.svg";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<CurrencyProvider>().symbol;

    final principal = double.tryParse(loan["amount"].toString()) ?? 0;
    final durationYears = int.tryParse(loan["durationYears"].toString()) ?? 0;
    final totalMonths = max(1, durationYears * 12);
    final startMY = loan["startMonthYear"] ?? "";
    final annualRate = LoanCalculator.getCurrentRate(loan);

    final emi = LoanCalculator.calculateEmi(
      principal: principal,
      annualRate: annualRate,
      months: totalMonths,
    );

    int monthsPaid = 0;
    if (startMY.isNotEmpty && startMY.contains('/')) {
      final parts = startMY.split('/');
      final startDay = int.tryParse(parts[0]) ?? 1;
      final startMonth = int.tryParse(parts[1]) ?? 1;
      final startYear = int.tryParse(parts[2]) ?? DateTime.now().year;

      final startDate = DateTime(startYear, startMonth, startDay);
      final today = DateTime.now();
      monthsPaid =
          (today.year - startDate.year) * 12 +
          (today.month - startDate.month) +
          1;
      monthsPaid = monthsPaid.clamp(0, totalMonths);
    }

    final bool isActive = monthsPaid < totalMonths;
    final totalPayable = emi * totalMonths;
    final paidEmi = emi * monthsPaid;
    final totalInterest = totalPayable - principal;
    final interestPaid = (paidEmi / totalPayable) * totalInterest;
    final remainingInterest = max(0, totalInterest - interestPaid);
    final remainingLoan = max(0, principal + remainingInterest - paidEmi);
    final nextEmiDate = isActive
        ? LoanCalculator.getNextEmiDate(startMY)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => LoanDetailScreen(
                  loan: LoanModel.fromJson(loan),
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.card
                  : AppColors.white,
              borderRadius: BorderRadius.circular(30),

              border: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : Border.all(color: Colors.grey.shade200),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.05),
              //     blurRadius: 4,
              //     offset: Offset(0, 4),
              //   ),
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppDarkColors.containerBg
                            : AppColors.softGreyBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        getLoanIconPath(loan["type"]),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppDarkColors.textPrimary
                            : AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loan["type"] ?? "Personal use",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppDarkColors.textPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),

                              Row(
                                children: [
                                  Container(
                                    height: 6,
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? AppDarkColors.success
                                                : AppColors.success)
                                          : (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? AppDarkColors.error
                                                : AppColors.error),

                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Status : ${isActive ? "Active" : "Inactive"}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w400,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppDarkColors.textSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _miniInfo(
                          context,
                          "Loan Amount",
                          "$currencySymbol${principal.toStringAsFixed(0)}",
                          "assets/images/i1.svg",
                        ),
                      ),

                      _divider(context),
                      SizedBox(width: 15),
                      Expanded(
                        child: _miniInfo(
                          context,
                          "Remaining Amount",
                          "$currencySymbol${remainingLoan.toStringAsFixed(0)}",
                          "assets/images/i2.svg",
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _miniInfo(
                          context,
                          "Total Interest",
                          "$currencySymbol${totalInterest.toStringAsFixed(0)}",
                          "assets/images/i3.svg",
                        ),
                      ),

                      _divider(context),
                      SizedBox(width: 15),
                      Expanded(
                        child: _miniInfo(
                          context,
                          "Next EMI",
                          isActive
                              ? LoanCalculator.formatDate(nextEmiDate!)
                              : "Completed",
                          "assets/images/i4.svg",
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
    );
  }

  Widget _miniInfo(
    BuildContext context,
    String title,
    String value,
    String svgPath,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              svgPath,
              width: 12,
              height: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.textSecondary
                  : AppColors.textSecondary,
            ),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.textSecondary
                    : AppColors.textSecondary,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lato',
            color: Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.textPrimary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      height: 36,
      width: 0.8,
      margin: EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.border
          : AppColors.borderGrey,
    );
  }
}
