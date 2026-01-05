import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReviewManager {
  AppReviewManager._();
  static final AppReviewManager instance = AppReviewManager._();

  // ---------------- CONFIG ----------------
  final int _minDaysInstalled = 1;
  final int _maxDailyPrompts = 1;

  // ---------------- STORE IDS ----------------
  final String _appStoreId = "6752597013"; // iOS App ID
  final String _playStoreId =
      "com.exypnos.technest.spendsmart"; // Android package name

  final InAppReview _inAppReview = InAppReview.instance;

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  // ---------------- INSTALL TRACK ----------------
  Future<void> onAppLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(
      'installDate',
      prefs.getInt('installDate') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ---------------- REVIEW CONDITIONS ----------------
  Future<bool> shouldShowReview() async {
    final prefs = await SharedPreferences.getInstance();

    // Already rated
    if (prefs.getBool('reviewDone') == true) return false;

    // Daily limit
    final count = prefs.getInt('reviewCount_${_todayKey()}') ?? 0;
    if (count >= _maxDailyPrompts) return false;

    // Installed days check
    final installDate = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('installDate')!,
    );
    if (DateTime.now().difference(installDate).inDays < _minDaysInstalled) {
      return false;
    }

    return true;
  }

  Future<void> logShown() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'reviewCount_${_todayKey()}';
    prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  // ---------------- MANUAL RATE (Settings → Rate Us) ----------------
  Future<void> manuallyRate() async {
    HapticFeedback.lightImpact();

    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    } else {
      _openStore();
    }
  }

  // ---------------- RATE NOW BUTTON ----------------
  Future<void> rateNow() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('reviewDone', true);

    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    } else {
      _openStore();
    }
  }

  // ---------------- AUTO REVIEW ----------------
  Future<void> attemptAutoReview() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    }
  }

  // ---------------- STORE FALLBACK ----------------
  void _openStore() {
    final Uri url = Platform.isIOS
        ? Uri.parse(
            "https://apps.apple.com/app/id$_appStoreId?action=write-review",
          )
        : Uri.parse(
            "https://play.google.com/store/apps/details?id=$_playStoreId",
          );

    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

void loanReviewDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (_) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ),
                Lottie.asset(
                  'assets/GIF/Rating.json',
                  height: 140,
                  repeat: false,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enjoying the Loan App?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  "Your feedback helps us improve loan tracking, EMI reminders, and insights.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    AppReviewManager.instance.rateNow();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Rate Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Maybe Later",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
