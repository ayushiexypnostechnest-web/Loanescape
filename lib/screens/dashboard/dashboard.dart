import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:loan_app/screens/dashboard/add_edit_loan_sheet.dart';
import 'package:loan_app/screens/dashboard/loan_card_widget.dart';
import 'package:loan_app/screens/primium_screen.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/loan_model.dart';
import '../../../services/loan_storage_service.dart';
import '../../../utils/loan_calculator.dart';

class DashboardScreen extends StatefulWidget {
  final List<LoanModel> loans;
  final void Function(List<LoanModel>) onViewAll;

  const DashboardScreen({
    super.key,
    required this.onViewAll,
    required this.loans,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  void refreshProfile() {
    loadUserData();
  }

  String userName = "User";
  File? profileImage;

  List<LoanModel> loans = [];

  @override
  void initState() {
    super.initState();
    loans = widget.loans;
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString("name") ?? "User";

      final imagePath = prefs.getString("profile_image");
      if (imagePath != null && File(imagePath).existsSync()) {
        profileImage = File(imagePath);
      }
    });
  }

  Future<void> _deleteLoan(int index) async {
    loans.removeAt(index);
    await LoanStorageService.saveAllLoans(loans);

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Loan deleted"),
        backgroundColor: Color(0xffBC0101),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
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
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 100,
              left: 20,
              right: 20,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loans.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Active Loan",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppDarkColors.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),

                      GestureDetector(
                        onTap: () => widget.onViewAll(loans),

                        child: Text(
                          "View All",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                if (loans.isNotEmpty) SizedBox(height: 14),

                loans.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 120,
                        ),
                        child: Column(
                          children: [
                            Lottie.asset(
                              Theme.of(context).brightness == Brightness.dark
                                  ? "assets/GIF/white2.json"
                                  : "assets/GIF/nodata_white.json",
                              height: 203,
                              fit: BoxFit.contain,
                              repeat: true,
                            ),

                            Text(
                              "we’re sorry, no data available at the moment. Please add your loan",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 11,
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
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),

                        itemCount: loans.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final loan = loans[index];

                          final rate = LoanCalculator.getCurrentRate(
                            loan.toJson(),
                          );

                          final years = int.tryParse(loan.durationYears) ?? 0;
                          final months = max(1, years * 12);

                          final emi = LoanCalculator.calculateEmi(
                            principal: loan.amount,
                            annualRate: rate,
                            months: months,
                          );

                          final loanMap = loan.toJson();
                          loanMap["emi"] = emi;

                          return ActiveLoanCard(
                            loan: loanMap,
                            index: index,
                            onEdit: () {
                              AddEditLoanSheet.open(
                                context: context,
                                index: index,
                                loans: loans,
                                onSave: (_) {},
                                onUpdate: (i, updatedLoan) async {
                                  loans[i] = updatedLoan;
                                  await LoanStorageService.saveAllLoans(loans);
                                  setState(() {});
                                },
                              );
                            },
                            onDelete: () => _deleteLoan(index),
                          );
                        },
                      ),
              ],
            ),
          ),

          SizedBox(
            height: MediaQuery.of(context).padding.top + 80,
            child: Material(
              elevation: 2,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.scaffold.withOpacity(0.5)
                  : AppColors.scaffold.withOpacity(0.5)),
              shadowColor: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.shadow
                  : AppColors.shadow,

              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top - 5,
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.scaffold.withOpacity(0.5)
                          : AppColors.scaffold.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: profileImage != null
                                ? Image.file(
                                    profileImage!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : SvgPicture.asset(
                                    "assets/images/user.svg",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),

                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppDarkColors.textMuted
                                      : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppDarkColors.textPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => PrimiumScreen(),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 26,
                                width: 85,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(34),
                                  color: Colors.white.withOpacity(0.3),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black.withOpacity(0.08),
                                  //     blurRadius: 6,
                                  //     offset: const Offset(0, 2),
                                  //   ),
                                  // ],
                                ),
                                child: SizedBox(width: double.infinity),
                              ),

                              SizedBox(
                                height: 26,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    100,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 15,
                                      sigmaY: 15,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        border: GradientBoxBorder(
                                          width: 1,
                                          gradient: SweepGradient(
                                            colors: [
                                              const Color(
                                                0xFF9C9C9C,
                                              ).withOpacity(0.50),
                                              const Color(
                                                0xFF9C9C9C,
                                              ).withOpacity(0.35),
                                              const Color(
                                                0xFFFFFFFF,
                                              ).withOpacity(0.50),
                                              const Color(
                                                0xFFFFFFFF,
                                              ).withOpacity(0.50),
                                              const Color(
                                                0xFF9C9C9C,
                                              ).withOpacity(0.35),
                                              const Color(0xFFF9F9F9),
                                              const Color(
                                                0xFFFFFFFF,
                                              ).withOpacity(0.50),
                                              const Color(
                                                0xFFF9F9F9,
                                              ).withOpacity(0.50),
                                            ],
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
                                          Text(
                                            "Upgrade",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? AppDarkColors.white
                                                  : AppColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
