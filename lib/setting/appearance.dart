import 'package:flutter/material.dart';
import 'package:loan_app/providers/theme_provider.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = themeProvider.themeMode;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.scaffold : AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color: isDark
                                  ? AppDarkColors.primary
                                  : AppColors.primary,
                            ),

                            Text(
                              "Settings",
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 15,
                                color: isDark
                                    ? AppDarkColors.textPrimary
                                    : AppColors.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Appearance",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppDarkColors.white : AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _sectionCard(context, [
                  _profileTile(context, "System", currentTheme),
                  _profileTile(context, "Light", currentTheme),
                  _profileTile(
                    context,
                    "Dark",
                    currentTheme,
                    showDivider: false,
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.searchbar : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _profileTile(
    BuildContext context,
    String value,
    AppThemeMode currentTheme, {
    bool showDivider = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    bool isSelected = false;
    switch (value) {
      case "System":
        isSelected = currentTheme == AppThemeMode.system;
        break;
      case "Light":
        isSelected = currentTheme == AppThemeMode.light;
        break;
      case "Dark":
        isSelected = currentTheme == AppThemeMode.dark;
        break;
    }

    return GestureDetector(
      onTap: () {
        switch (value) {
          case "System":
            themeProvider.setTheme(AppThemeMode.system);
            break;
          case "Light":
            themeProvider.setTheme(AppThemeMode.light);
            break;
          case "Dark":
            themeProvider.setTheme(AppThemeMode.dark);
            break;
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Colors.white
                          : isSelected
                          ? const Color(0xff001230)
                          : Colors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              thickness: 0.8,
              indent: 16,
              color: Color(0xffCED4DA),
            ),
        ],
      ),
    );
  }
}
