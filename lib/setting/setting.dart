import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loan_app/cryptography.dart';
import 'package:loan_app/models/profile.dart';
import 'package:loan_app/screens/primium_screen.dart';
import 'package:loan_app/screens/sign_in.dart';
import 'package:loan_app/services/google_signin.dart';
import 'package:loan_app/setting/help_center.dart';
import 'package:loan_app/setting/appearance.dart';
import 'package:loan_app/setting/currency.dart';
import 'package:loan_app/setting/personal_detail.dart';
import 'package:loan_app/setting/review.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingPage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;
  final bool compact;
  const SettingPage({super.key, this.onProfileUpdated, required this.compact});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _appVersion = "";
  String _name = "";
  String _email = "";
  File? _profileImage;

  final ScrollController _controller = ScrollController();

  void _confirmDelete(BuildContext context) {
    showPlatformDialog(
      context: context,
      title: "Delete Account?",
      message:
          "This will permanently remove your account and all related data.",
      confirmText: "Delete",
      assetIcon: "assets/images/delete.svg",
      confirmColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF001230)
          : const Color(0xFFAFCDFF),
      onConfirm: () async {
        final supabase = Supabase.instance.client;

        await supabase.from('users').delete().eq('email', _email);

        try {
          await GoogleSignin.disconnect();
        } catch (_) {}

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignIn()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your account has been deleted"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _confirmLogOut(BuildContext context) {
    showPlatformDialog(
      context: context,
      title: "Sign Out?",
      message: "You can sign back in anytime.",
      confirmText: "Sign Out",
      assetIcon: "assets/images/sign_out.svg",
      confirmColor: const Color(0xffBC0101),
      onConfirm: () async {
        await GoogleSignin.logout();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignIn()),
          (route) => false,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _loadAppVersion();
    _loadUserData();
  }

  Future<void> _openPersonalDetails() async {
    final result = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (ctx) => PersonalDetailScreen(
          name: _name,
          email: _email,
          imagePath: _profileImage?.path,
        ),
      ),
    );
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("name", result.name);
      await prefs.setString("email", result.email);
      if (result.imagePath != null) {
        await prefs.setString("profile_image", result.imagePath!);
      }
      setState(() {
        _name = result.name;
        _email = result.email;
        _profileImage = result.imagePath != null
            ? File(result.imagePath!)
            : null;
      });
      widget.onProfileUpdated?.call();
    }
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "${packageInfo.version}";
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _name = prefs.getString("name") ?? "User Name";
      _email = prefs.getString("email") ?? "user@example.com";

      final imagePath = prefs.getString("profile_image");
      if (imagePath != null && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      } else {
        _profileImage = null;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,

      body: SafeArea(
        top: false,
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              expandedHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppDarkColors.scaffold.withOpacity(0.5)
                  : AppColors.scaffold.withOpacity(0.5),
              shadowColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : AppColors.shadow,
              surfaceTintColor: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : AppColors.white,

              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final topPadding = MediaQuery.of(context).padding.top;
                      final compact =
                          constraints.maxHeight <= kToolbarHeight + topPadding;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          compact ? topPadding : topPadding + 15,
                          20,
                          0,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!compact)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            if (compact)
                              Center(
                                child: Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileCard(
                    context,
                    name: _name,
                    email: _email,
                    image: _profileImage,
                    onTap: _openPersonalDetails,
                  ),
                  const SizedBox(height: 10),

                  _sectionTitle("ACCOUNT"),
                  _sectionCard([
                    //_settingsTile("assets/icons/i1.svg", "Personal Information"),
                    _settingsTile(
                      "assets/icons/i2.svg",
                      "Get Premium",
                      showDivider: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const PrimiumScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  _sectionTitle("NOTIFICATIONS"),
                  _sectionCard([
                    _settingsTile(
                      "assets/icons/i3.svg",
                      "EMI Reminder",
                      showDivider: false,
                      showChevron: false,
                    ),
                  ]),
                  _sectionTitle("PREFERENCE"),
                  _sectionCard([
                    _settingsTile(
                      "assets/icons/i4.svg",
                      "Currency",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => CurrencyScreen()),
                        );
                      },
                    ),
                    _settingsTile(
                      "assets/icons/i5.svg",
                      "Appearance",
                      showDivider: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AppearanceScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  _sectionTitle("SUPPORT"),
                  _sectionCard([
                    _settingsTile(
                      "assets/icons/i6.svg",
                      "Help Center",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen(),
                          ),
                        );
                      },
                    ),

                    _settingsTile("assets/icons/i7.svg", "Restore Purchase"),
                    _settingsTile(
                      "assets/icons/i8.svg",
                      "Rate Us",
                      onTap: () {
                        loanReviewDialog(context);
                      },
                      showDivider: false,
                    ),
                  ]),

                  _sectionTitle("ABOUT"),
                  _sectionCard([
                    _settingsTile("assets/icons/i9.svg", "Privacy Policy"),
                    _settingsTile("assets/icons/i10.svg", "Terms Of Use"),
                    _settingsTile(
                      "assets/icons/i11.svg",
                      "Version",
                      trailing: Text(
                        _appVersion.isNotEmpty ? _appVersion : "Loading...",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Lato',
                        ),
                      ),
                      showDivider: false,
                    ),
                  ]),

                  _sectionTitle("DANGER ZONE"),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,

                    onTap: () {
                      _confirmDelete(context);
                    },
                    child: _sectionCard([
                      _settingsTile(
                        "assets/icons/i12.svg",
                        "Delete Account",
                        showDivider: false,
                      ),
                    ]),
                  ),

                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,

                    onTap: () {
                      _confirmLogOut(context);
                    },
                    child: _sectionCard([
                      _settingsTile(
                        "assets/icons/i13.svg",
                        "Sign Out",
                        showDivider: false,
                        showChevron: false,
                        textColor: Color(0xffFF0000),
                        iconColor: Color(0xffFF0000),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),

      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 11,
          color: Color(0xff919AA7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),

      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.setting
            : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        //border: Border.all(color: Colors.grey.shade300),
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

  Widget _settingsTile(
    String icon,
    String title, {
    bool showDivider = true,
    bool showChevron = true,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon,
                  height: 22,
                  width: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? (iconColor ?? AppDarkColors.white)
                      : (iconColor ?? AppColors.black),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? (textColor ?? Colors.white)
                          : (textColor ?? Colors.black),
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing
                else if (showChevron)
                  SvgPicture.asset("assets/images/right_arrow.svg"),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              thickness: 0.8,
              height: 0,
              indent: 54,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff303840)
                  : const Color(0xffCED4DA),
            ),
        ],
      ),
    );
  }
}

Widget _profileCard(
  BuildContext context, {
  required String name,
  required String email,
  required File? image,
  required VoidCallback onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: onTap,

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.setting
                : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: image != null
                      ? Image.file(
                          image,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                      : SvgPicture.asset(
                          "assets/images/user.svg",
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        color: Color(0xff989898),
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset("assets/images/right_arrow.svg"),
            ],
          ),
        ),
      ),
    ],
  );
}
