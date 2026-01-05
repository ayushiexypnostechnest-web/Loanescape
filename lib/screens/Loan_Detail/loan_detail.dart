import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loan_app/models/loan_model.dart';
import 'package:loan_app/providers/currency_provider.dart';
import 'package:loan_app/screens/Loan_Detail/floating_button.dart';
import 'package:loan_app/screens/Loan_Detail/loandetail_topbar.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:loan_app/utils/loan_calculator.dart';
import 'package:provider/provider.dart';

class LoanDetailScreen extends StatefulWidget {
  final LoanModel loan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LoanDetailScreen({
    super.key,
    required this.loan,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;

  bool _showInterestTab = true;
  final ScrollController _controller = ScrollController();
  bool _compactHeader = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _compactHeader = _controller.offset > 40;
      });
    });
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _circleAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeOutCubic,
    );

    _circleController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _circleController.dispose();
    super.dispose();
  }

  //DELETE POP-POP
  void _confirmDelete(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? AppDarkColors.scaffold : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/images/delete.svg",
                  color: isDark ? AppDarkColors.white : Colors.black,
                ),

                SizedBox(height: 10),

                Text(
                  "Delete Loan?",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "This will permanently remove this loan and all related data.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 39,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(0xffD9D9D9),
                              borderRadius: BorderRadius.circular(33),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onDelete();
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 39,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xffBC0101),
                              borderRadius: BorderRadius.circular(33),
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<CurrencyProvider>().symbol;
    final double principal =
        double.tryParse(widget.loan.amount.toString()) ?? 0;
    final double annualRate = double.tryParse(widget.loan.rate.toString()) ?? 0;
    final int durationYears =
        int.tryParse(widget.loan.durationYears.toString()) ?? 0;

    final int totalMonths = max(1, durationYears * 12);

    // Calculate EMI using LoanCalculator
    final double emi = LoanCalculator.calculateEmi(
      principal: principal,
      annualRate: annualRate,
      months: totalMonths,
    );

    // Parse start date
    final String startMY = widget.loan.startMonthYear;
    DateTime startDate = DateTime.now();

    if (startMY.isNotEmpty && startMY.contains('/')) {
      final parts = startMY.split('/');
      final int day = parts.length > 0 ? int.tryParse(parts[0]) ?? 1 : 1;
      final int month = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
      final int year = parts.length > 2
          ? int.tryParse(parts[2]) ?? DateTime.now().year
          : DateTime.now().year;
      startDate = DateTime(year, month, day);
    }

    // Calculate end date
    final DateTime endDate = LoanCalculator.getEndDate(startDate, totalMonths);

    // Calculate months paid
    final DateTime today = DateTime.now();
    final int monthsPaid =
        ((today.year - startDate.year) * 12 +
                (today.month - startDate.month) +
                1)
            .clamp(0, totalMonths);

    final int remainingMonths = totalMonths - monthsPaid;
    final bool isLoanCompleted = remainingMonths <= 0;

    // Total interest & remaining loan
    final double totalPayable = emi * totalMonths;
    final double totalInterest = totalPayable - principal;
    final double paidEmi = emi * monthsPaid;
    final double interestPaid = (paidEmi / totalPayable) * totalInterest;
    final double remainingInterest = max(0, totalInterest - interestPaid);
    final double remainingLoan = max(
      0,
      principal + remainingInterest - paidEmi,
    );

    // Next EMI date
    final DateTime? nextEmiDate = isLoanCompleted
        ? null
        : LoanCalculator.getNextEmiDate(startMY);

    // Contributions for current month
    final double monthlyRate = annualRate / 12 / 100;
    // Outstanding principal approximation
    final double outstandingPrincipal = max(
      0,
      principal - (paidEmi - interestPaid),
    );

    // Correct interest for current EMI
    final double interestContribution = max(
      0,
      outstandingPrincipal * monthlyRate,
    );

    // Principal part of EMI
    final double principalContribution = max(0, emi - interestContribution);

    // Remaining duration
    final int yearsLeft = remainingMonths ~/ 12;
    final int monthsLeft = remainingMonths % 12;

    // Loan progress (0.0 to 1.0)
    final double loanProgress = (monthsPaid / totalMonths).clamp(0.0, 1.0);

    // EMI for display
    final double emiAmount = emi;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          LoanDetailSliverTopBar(
            compact: _compactHeader,
            title: "Dashboard",
            subTitle: "Loan Information",
            onBackTap: () => Navigator.pop(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppDarkColors.card
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(30),

                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset.zero,
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Loan summary card",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.textPrimary
                                            : AppColors.textPrimary,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "A complete snapshot of your loan details, remaining tenure, and overall status.",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.textSecondary
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _confirmDelete(context),
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.inputBg
                                            : AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppDarkColors.inputBg
                                              : AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: widget.onEdit,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.inputBg
                                            : AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppDarkColors.inputBg
                                              : AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppDarkColors.smallcard.withOpacity(0.08)
                                  : AppColors.smallcard.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.scaffold
                                            : AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/images/i.svg',
                                          height: 8,
                                          width: 15,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppDarkColors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Text(
                                      "Remaining Amount",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.white
                                            : AppColors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                    top: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$currencySymbol${remainingLoan.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "of $currencySymbol${principal.toStringAsFixed(0)} loan amount",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppDarkColors.white
                                              : AppColors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 23),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoBox(
                                  'assets/images/interest.svg',
                                  'Interest Rate',
                                  '${annualRate.toStringAsFixed(0)}% p.a.',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildInfoBox(
                                  'assets/images/tenture.svg',
                                  'Tenure Remaining',
                                  '${monthsLeft + yearsLeft * 12} Month',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _buildLoanDates(startDate, endDate),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppDarkColors.card
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(30),

                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset.zero,
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment info card",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.textPrimary
                                            : AppColors.textPrimary,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Monitor your monthly EMI schedule, payments made so far, and upcoming dues.",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        color: Color(0xff919AA7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          _buildNextEmiCard(
                            isLoanCompleted
                                ? "Loan Completed"
                                : LoanCalculator.formatDate(nextEmiDate!),
                            isLoanCompleted
                                ? "$currencySymbol${0.toStringAsFixed(0)}"
                                : "$currencySymbol${emi.toStringAsFixed(0)}",
                          ),

                          const SizedBox(height: 23),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppDarkColors.searchbar
                                  : AppColors.softGreyBg,
                              borderRadius: BorderRadius.circular(20),

                              border: isDark
                                  ? null
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Loan progress",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.smalltext
                                            : AppColors.smalltext,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "$monthsPaid / $totalMonths",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 10,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.smalltext
                                            : AppColors.smalltext,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: loanProgress,
                                    minHeight: 6,
                                    backgroundColor: isDark
                                        ? const Color(0xFF234570)
                                        : const Color(0xFFE6E9EF),
                                    color: isDark
                                        ? AppDarkColors.primaryDark
                                        : AppColors.primaryDark,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "${(loanProgress * 100).toStringAsFixed(0)}% complete",
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 10,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppDarkColors.smalltext
                                          : AppColors.smalltext,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 23),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppDarkColors.searchbar
                                  : AppColors.softGreyBg,
                              borderRadius: BorderRadius.circular(20),
                              border: isDark
                                  ? null
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  /// LEFT SIDE — Paid Till Date
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/paid.svg',
                                              width: 15,
                                              height: 15,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Paid Till Date",
                                              style: TextStyle(
                                                fontFamily: 'Lato',
                                                fontSize: 13,
                                                color: isDark
                                                    ? AppDarkColors.smalltext
                                                    : AppColors.smalltext,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          isLoanCompleted
                                              ? LoanCalculator.formatDate(
                                                  endDate,
                                                )
                                              : LoanCalculator.formatDate(
                                                  nextEmiDate!,
                                                ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  VerticalDivider(
                                    thickness: 1,
                                    color: const Color(0xffCED4DA),
                                  ),

                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/remaining.svg',
                                                width: 15,
                                                height: 15,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Remaining EMIs",
                                                style: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontSize: 13,
                                                  color: isDark
                                                      ? AppDarkColors.smalltext
                                                      : AppColors.smalltext,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "$remainingMonths EMIs Left",
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInterestEmiTabCard(
                      totalInterest: totalInterest,
                      paidInterest: interestPaid,
                      remainingInterest: remainingInterest,
                      emiAmount: emiAmount,
                      principalContribution: principalContribution,
                      interestContribution: interestContribution,
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 140),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingAiButtons(
        loan: widget.loan,
        onWhatIfTap: () {
          HapticFeedback.mediumImpact();
        },
        onAiTap: () {
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  Widget _buildInfoBox(String svgPath, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),

      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.searchbar
            : AppColors.softGreyBg,
        borderRadius: BorderRadius.circular(18),

        border: isDark ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(svgPath),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.smalltext
                      : AppColors.smalltext,
                  fontSize: 12,
                  fontFamily: 'Lato',
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextEmiCard(String nextDate, String amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.smallcard.withOpacity(0.08)
            : AppColors.smallcard.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.scaffold
                      : AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.black,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Next EMI Date",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.black,
                  fontFamily: 'Lato',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              nextDate,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Divider(color: Colors.grey.shade300, height: 24),

          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.scaffold
                      : AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.currency_rupee,
                  size: 18,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.black,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Next EMI Amount",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.black,
                  fontFamily: 'Lato',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              amount,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDates(DateTime startDate, DateTime endDate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.searchbar : AppColors.softGreyBg,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            /// LEFT SIDE
            Expanded(
              child: _dateColumn(
                title: "Loan start date",
                date: LoanCalculator.formatDate(startDate),
              ),
            ),

            VerticalDivider(thickness: 1, color: Colors.grey.shade300),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _dateColumn(
                  title: "Loan end date",
                  date: LoanCalculator.formatDate(endDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateColumn({required String title, required String date}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontFamily: 'Lato')),
        const SizedBox(height: 4),
        Text(date, style: TextStyle(fontSize: 15, fontFamily: 'Lato')),
      ],
    );
  }

  Widget _buildInterestEmiTabCard({
    required double totalInterest,
    required double paidInterest,
    required double remainingInterest,
    required double emiAmount,
    required double principalContribution,
    required double interestContribution,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double interestProgress = totalInterest == 0
        ? 0
        : paidInterest / totalInterest;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.card
            : AppColors.white,
        borderRadius: BorderRadius.circular(30),

        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset.zero,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _showInterestTab = true);
                    _circleController.reset();
                    _circleController.forward();
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: _showInterestTab
                              ? const Color(0xff243B64)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Interest Card",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _showInterestTab
                              ? (isDark ? AppDarkColors.white : Colors.black)
                              : (isDark
                                    ? AppDarkColors.textMuted
                                    : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _showInterestTab = false);
                    _circleController.reset();
                    _circleController.forward();
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: !_showInterestTab
                              ? const Color(0xff243B64)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "EMI Contribution",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: !_showInterestTab
                              ? (isDark ? AppDarkColors.white : Colors.black)
                              : (isDark
                                    ? AppDarkColors.textMuted
                                    : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _showInterestTab
              ? _interestCardContent(
                  totalInterest,
                  paidInterest,
                  remainingInterest,
                  interestProgress,
                )
              : _emiContributionContent(
                  emiAmount: emiAmount,
                  principalContribution: principalContribution,
                  interestContribution: interestContribution,
                ),
        ],
      ),
    );
  }

  Widget _interestCardContent(
    double total,
    double paid,
    double remaining,
    double progress,
  ) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // evenly distributes space
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Your first element (like title and description)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Interest card",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "View total interest paid, remaining interest amount, and overall interest progress.",
              style: TextStyle(
                color: const Color(0xff919AA7),
                fontSize: 12,
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),

        // The middle content (circular progress and legends, etc)
        Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: AnimatedBuilder(
                      animation: _circleAnimation,
                      builder: (_, __) {
                        return CircularProgressIndicator(
                          value: progress * _circleAnimation.value,
                          strokeWidth: 14,
                          backgroundColor: const Color(0xffE6E9EF),
                          color: const Color(0xff41AE76),
                        );
                      },
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _circleAnimation,
                    builder: (_, __) {
                      return Text(
                        "${max(0, progress * _circleAnimation.value * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(const Color(0xff41AE76), "Complete"),
                const SizedBox(width: 20),
                _legendDot(const Color(0xffE6E9EF), "Incomplete"),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),

        // Bottom content (interest rows)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _interestRow(
                  Icons.trending_up,
                  "Total Interest",
                  total,
                  Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.black,
                ),
                const Divider(indent: 25, color: Color(0xffCED4DA)),

                _interestRow(
                  Icons.check_circle_outline,
                  "Paid Interest",
                  paid,
                  const Color(0xff2E7D32),
                ),
                const Divider(indent: 25, color: Color(0xffCED4DA)),
                _interestRow(
                  Icons.access_time,
                  "Remaining Interest",
                  remaining,
                  const Color(0xffBC0101),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _emiContributionContent({
    required double emiAmount,
    required double principalContribution,
    required double interestContribution,
  }) {
    double progress = interestContribution / emiAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "EMI contribution",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Track how each EMI reduces your loan and interest.",
          style: TextStyle(
            fontFamily: 'Lato',
            color: const Color(0xff919AA7),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 30),

        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: AnimatedBuilder(
                  animation: _circleAnimation,
                  builder: (_, __) {
                    return CircularProgressIndicator(
                      value: progress * _circleAnimation.value,
                      strokeWidth: 14,
                      backgroundColor: const Color(0xffE6E9EF),
                      color: const Color(0xff41AE76),
                    );
                  },
                ),
              ),
              AnimatedBuilder(
                animation: _circleAnimation,
                builder: (_, __) {
                  return Text(
                    "${max(0, progress * _circleAnimation.value * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(const Color(0xff41AE76), "Interest Amount"),
            const SizedBox(width: 16),
            _legendDot(const Color(0xffE6E9EF), "Principal Amount"),
          ],
        ),

        const SizedBox(height: 30),

        /// Cards
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _emiRow(
                  color: Color(0xff00601D),
                  icon: Icons.currency_rupee,
                  title: "EMI Amount",
                  value: emiAmount,
                ),
                const Divider(indent: 25, color: Color(0xffCED4DA)),
                _emiRow(
                  color: Color(0xffB47035),
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Principal Contribution",
                  value: principalContribution,
                ),
                const Divider(indent: 25, color: Color(0xffCED4DA)),
                _emiRow(
                  color: Color(0xff00601D),
                  icon: Icons.percent,
                  title: "Interest Contribution",
                  value: interestContribution,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontFamily: 'Lato')),
      ],
    );
  }

  Widget _emiRow({
    required IconData icon,
    required Color color,
    required String title,
    required double value,
  }) {
    final currencySymbol = context.watch<CurrencyProvider>().symbol;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 14, fontFamily: 'Lato')),
            ],
          ),
          Text(
            "$currencySymbol${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _interestRow(IconData icon, String title, double value, Color color) {
    final currencySymbol = context.watch<CurrencyProvider>().symbol;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                  ),
                ],
              ),
              Text(
                "$currencySymbol${value.toStringAsFixed(0)}",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
