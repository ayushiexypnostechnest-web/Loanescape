import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loan_app/models/loan_model.dart';
import 'package:loan_app/screens/AI/ai_assistant.dart';
import 'package:loan_app/screens/dashboard/add_edit_loan_sheet.dart';
import 'package:loan_app/screens/viewall_screen.dart';
import 'package:loan_app/services/loan_storage_service.dart';
import 'package:loan_app/setting/setting.dart';
import 'package:loan_app/screens/dashboard/dashboard.dart';
import 'package:loan_app/theme/app_colors.dart';

final GlobalKey<DashboardScreenState> dashboardKey = GlobalKey();

enum AppPage { dashboard, ai, settings }

class DashboardBottomBar extends StatefulWidget {
  const DashboardBottomBar({super.key});

  @override
  State<DashboardBottomBar> createState() => _DashboardBottomBarState();
}

class _DashboardBottomBarState extends State<DashboardBottomBar> {
  AppPage _currentPage = AppPage.dashboard;

  List<LoanModel> _loans = [];
  bool _isLoading = true;
  bool _showViewAll = false;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    final loans = await LoanStorageService.loadLoans();
    setState(() {
      _loans = loans;
      _isLoading = false;
    });
  }

  void _onTap(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (index == 0) _currentPage = AppPage.dashboard;
      if (index == 1) _currentPage = AppPage.ai;
      if (index == 2) _currentPage = AppPage.settings;
    });
  }

  int _selectedIndex() {
    switch (_currentPage) {
      case AppPage.ai:
        return 1;
      case AppPage.settings:
        return 2;
      default:
        return 0;
    }
  }

  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_currentPage != AppPage.dashboard) {
          setState(() => _currentPage = AppPage.dashboard);
          return false;
        }

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Press back again to exit"),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return false;
        }

        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex(),
          children: [
            _buildDashboard(),
            const AiAssistant(),
            SettingPage(
              onProfileUpdated: () {
                dashboardKey.currentState?.refreshProfile();
              },
              compact: false,
            ),
          ],
        ),

        bottomNavigationBar: _buildBottomBar(isDark),
      ),
    );
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _showViewAll
            ? ViewallScreen(
                key: const ValueKey('viewAll'),
                loans: _loans,
                compact: false,
                onBack: () => setState(() => _showViewAll = false),
              )
            : DashboardScreen(
                key: dashboardKey,
                loans: _loans,
                onViewAll: (loans) {
                  setState(() {
                    _loans = loans;
                    _showViewAll = true;
                  });
                },
              ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.primary
            : AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Icon(
          Icons.add,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppDarkColors.card
              : AppColors.white,
          size: 30,
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          AddEditLoanSheet.open(
            context: context,
            loans: _loans,
            onSave: (loan) async {
              _loans.add(loan);
              await LoanStorageService.saveAllLoans(_loans);
              setState(() {});
            },
            onUpdate: (_, __) {},
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 40,
        right: 40,
        top: 15,
        bottom: Platform.isIOS ? MediaQuery.of(context).padding.bottom : 15,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.scaffold : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xff757575).withOpacity(0.20)
                : AppColors.shadow.withOpacity(0.12),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(
            0,
            'Home',
            'assets/images/H.svg',
            'assets/images/home_fill.svg',
          ),
          _navItem(
            1,
            'Ask AI',
            'assets/images/ai.svg',
            'assets/images/robot_fill.svg',
          ),
          _navItem(
            2,
            'Settings',
            'assets/images/setting.svg',
            'assets/images/setting_fill.svg',
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, String label, String icon, String filledIcon) {
    final isSelected = _selectedIndex() == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedColor = isDark ? AppDarkColors.primary : AppColors.primary;
    final textColor = isSelected
        ? (isDark ? AppDarkColors.text : AppColors.white)
        : (isDark ? AppDarkColors.textSecondary : AppColors.tabInactive);

    return InkWell(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(isSelected ? filledIcon : icon, color: textColor),
            if (isSelected) const SizedBox(width: 8),
            if (isSelected)
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
