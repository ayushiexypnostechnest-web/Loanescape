import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptography/cryptography.dart';
import 'package:loan_app/theme/app_colors.dart';

Future<void> showPlatformDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String assetIcon,
  required Color confirmColor,
  required VoidCallback onConfirm,
}) async {
  if (Platform.isIOS) {
    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.light),
        child: CupertinoAlertDialog(
          title: Column(
            children: [
              SvgPicture.asset(assetIcon, height: 40),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(message, textAlign: TextAlign.center),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: Text(
                confirmText,
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
              onPressed: () async {
                Navigator.pop(context);

                // Optional: cryptography logic
                final algorithm = Sha256();
                final hash = await algorithm.hash("$title action".codeUnits);
                print("Hash: ${hash.bytes}");

                onConfirm();
              },
            ),
          ],
        ),
      ),
    );
  } else {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.black : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isDark
                ? Border.all(color: const Color(0xFF323232), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.25),
                blurRadius: isDark ? 4 : 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assetIcon,
                height: 50,
                color: isDark ? AppDarkColors.white : Colors.black,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black54,
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
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.25)
                                  : confirmColor,
                            ),
                          ),

                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : confirmColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          final algorithm = Sha256();
                          final hash = await algorithm.hash(
                            "$title action".codeUnits,
                          );
                          print("Hash: ${hash.bytes}");
                          onConfirm();
                        },
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: confirmColor,
                            borderRadius: BorderRadius.circular(22),
                          ),

                          child: Text(
                            confirmText,
                            style: const TextStyle(
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
      ),
    );
  }
}
