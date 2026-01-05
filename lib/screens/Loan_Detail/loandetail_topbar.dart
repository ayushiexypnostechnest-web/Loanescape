import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loan_app/theme/app_colors.dart';

class LoanDetailSliverTopBar extends StatelessWidget {
  final bool compact;
  final String title;
  final String subTitle;
  final VoidCallback onBackTap;

  const LoanDetailSliverTopBar({
    super.key,
    required this.compact,
    required this.title,
    required this.subTitle,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      expandedHeight: 105,
      automaticallyImplyLeading: false,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold.withOpacity(0.5)
          : AppColors.scaffold.withOpacity(0.5)),
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.transparent
          : AppColors.shadow,
      surfaceTintColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : AppColors.white,

      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, compact ? 12 : 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: onBackTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 19,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppDarkColors.primary
                                    : AppColors.primary,
                              ),

                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppDarkColors.textPrimary
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (compact)
                        Text(
                          subTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppDarkColors.textPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  if (!compact) ...[
                    Text(
                      subTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppDarkColors.textPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
