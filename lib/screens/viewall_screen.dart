import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/animation.dart';
import 'package:loan_app/models/loan_model.dart';
import 'package:loan_app/screens/dashboard/add_edit_loan_sheet.dart';
import 'package:loan_app/screens/dashboard/loan_card_widget.dart';
import 'package:loan_app/services/loan_storage_service.dart';
import 'package:loan_app/theme/app_colors.dart';

class ViewallScreen extends StatefulWidget {
  final List<LoanModel> loans;
  final bool compact;
  final VoidCallback? onBack;

  const ViewallScreen({
    super.key,
    required this.loans,
    required this.compact,
    required this.onBack,
  });

  @override
  State<ViewallScreen> createState() => _ViewallScreenState();
}

class _ViewallScreenState extends State<ViewallScreen> {
  final ScrollController _controller = ScrollController();
  bool compact = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        compact = _controller.offset > 40;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBackWithAnimation() async {
    if (_isClosing) return;

    setState(() => _isClosing = true);

    // wait for staggered animation to finish
    await Future.delayed(
      Duration(milliseconds: (widget.loans.length * 50) + 300),
    );

    if (mounted && widget.onBack != null) {
      widget.onBack!();
    }
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackWithAnimation();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppDarkColors.scaffold : AppColors.scaffold,
        body: CustomScrollView(
          controller: _controller,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              expandedHeight: 150,
              collapsedHeight: kToolbarHeight,
              automaticallyImplyLeading: false,
              backgroundColor: isDark
                  ? AppDarkColors.scaffold.withOpacity(0.5)
                  : AppColors.scaffold.withOpacity(0.5),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              compact ? 12 : 16,
                              20,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () {
                                          _handleBackWithAnimation();
                                        },

                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              size: 18,
                                              color: isDark
                                                  ? AppDarkColors.primary
                                                  : AppColors.primary,
                                            ),
                                            Text(
                                              "Dashboard",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'Lato',
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

                                    if (compact)
                                      StaggeredListItem(
                                        index: 0,
                                        isClosing: _isClosing,
                                        child: Text(
                                          "Your Loans",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? AppDarkColors.textPrimary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                if (!compact) ...[
                                  const SizedBox(height: 18),

                                  StaggeredListItem(
                                    index: 1,
                                    isClosing: _isClosing,
                                    child: Text(
                                      "Your Loans",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppDarkColors.textPrimary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  StaggeredListItem(
                                    index: 2,
                                    isClosing: _isClosing,
                                    child: Container(
                                      height: 41,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppDarkColors.searchbar
                                            : AppColors.inputBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 12),
                                            child: Icon(
                                              Icons.search,
                                              size: 20,
                                              color: Color(0xFF797979),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              cursorColor: isDark
                                                  ? Colors.white.withOpacity(
                                                      0.7,
                                                    )
                                                  : Colors.black54,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "Search your loan here",
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontSize: 13,
                                                  color: isDark
                                                      ? AppDarkColors.textMuted
                                                      : AppColors.textMuted,
                                                ),
                                                border: InputBorder.none,
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(
                left: 20,
                bottom: 10,
                right: 20,
                top: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final loan = widget.loans[index];
                  return StaggeredListItem(
                    isClosing: _isClosing,
                    index: index,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDate(loan.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppDarkColors.textSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ActiveLoanCard(
                          loan: loan.toJson(),
                          index: index,
                          onEdit: () {
                            AddEditLoanSheet.open(
                              context: context,
                              index: index,
                              loans: widget.loans,
                              onSave: (_) {},
                              onUpdate: (i, updatedLoan) async {
                                widget.loans[i] = updatedLoan;
                                await LoanStorageService.saveAllLoans(
                                  widget.loans,
                                );
                                setState(() {});
                              },
                            );
                          },
                          onDelete: () {
                            widget.loans.removeAt(index);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  );
                }, childCount: widget.loans.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
