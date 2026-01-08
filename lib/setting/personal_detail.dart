import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loan_app/models/profile.dart';
import 'package:loan_app/screens/image.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalDetailScreen extends StatefulWidget {
  final String name;
  final String email;
  final String? imagePath;

  const PersonalDetailScreen({
    super.key,
    required this.name,
    required this.email,
    this.imagePath,
  });

  @override
  State<PersonalDetailScreen> createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hasChanges = false;
  late String _initialName;
  late String _initialEmail;
  File? _profileImage;
  void showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _checkForChanges() {
    final profileChanged =
        _nameController.text != _initialName ||
        _emailController.text != _initialEmail;

    final passwordChanged =
        _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;

    setState(() {
      _hasChanges = profileChanged || passwordChanged;
    });
  }

  Future<bool> _updatePasswordIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString("password");

    // If user didn’t try to change password
    if (_currentPasswordController.text.isEmpty &&
        _newPasswordController.text.isEmpty &&
        _confirmPasswordController.text.isEmpty) {
      return true;
    }

    if (storedPassword == null) {
      _showError("No password found. Please login again.");
      return false;
    }

    if (_currentPasswordController.text != storedPassword) {
      _showError("Current password is incorrect");
      return false;
    }

    if (_newPasswordController.text.length < 6) {
      _showError("New password must be at least 6 characters");
      return false;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError("New passwords do not match");
      return false;
    }

    await prefs.setString("password", _newPasswordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text("Password updated successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _initialName = widget.name;
    _initialEmail = widget.email;

    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);

    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _currentPasswordController.addListener(_checkForChanges);
    _newPasswordController.addListener(_checkForChanges);
    _confirmPasswordController.addListener(_checkForChanges);

    if (widget.imagePath != null && File(widget.imagePath!).existsSync()) {
      _profileImage = File(widget.imagePath!);
    } else {
      _profileImage = null;
    }
  }

  void showIOSLoader(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Loading",
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CupertinoActivityIndicator(
                radius: 14,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  void hideIOSLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> onEditImageTap() async {
    try {
      HapticFeedback.mediumImpact();

      showIOSLoader(context);

      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      hideIOSLoader(context);

      if (image == null) return;

      final savedImage = File(image.path);

      setState(() {
        _profileImage = savedImage;
        _hasChanges = true;
      });
    } catch (e) {
      hideIOSLoader(context);
      debugPrint("Image pick error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
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
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,

                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppDarkColors.primary
                                  : AppColors.primary,
                            ),

                            Text(
                              "Settings",
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppDarkColors.textPrimary
                                    : AppColors.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppDarkColors.white
                                : AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,

                  onTap: onEditImageTap,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(
                                    _profileImage!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                    errorBuilder: (_, __, ___) {
                                      return SvgPicture.asset(
                                        "assets/images/user.svg",
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : SvgPicture.asset(
                                    "assets/images/user.svg",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _sectionTitle("PROFILE"),
                _sectionCard([
                  _editableField(_nameController),
                  _editableField(_emailController, showDivider: false),
                ]),
                SizedBox(height: 10),
                _sectionTitle("PASSWORD"),
                _sectionCard([
                  _passwordField(
                    "Current password",
                    controller: _currentPasswordController,
                  ),
                  _passwordField(
                    "New password",
                    controller: _newPasswordController,
                  ),
                  _passwordField(
                    "Confirm new password",
                    controller: _confirmPasswordController,
                    showDivider: false,
                  ),
                ]),

                const SizedBox(height: 39),
                GestureDetector(
                  onTap: _hasChanges
                      ? () async {
                          final passwordOk = await _updatePasswordIfNeeded();
                          if (!passwordOk) return;

                          final prefs = await SharedPreferences.getInstance();

                          await prefs.setString("name", _nameController.text);
                          await prefs.setString("email", _emailController.text);
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();

                          if (_profileImage != null &&
                              _profileImage!.existsSync()) {
                            await prefs.setString(
                              "profile_image",
                              _profileImage!.path,
                            );
                          }

                          Navigator.pop(
                            context,
                            UserProfile(
                              name: _nameController.text,
                              email: _emailController.text,
                              imagePath: _profileImage?.path,
                            ),
                          );

                          await Supabase.instance.client
                              .from('users')
                              .update({
                                'name': _nameController.text,
                                'email': _emailController.text,
                              })
                              .eq('email', widget.email);
                        }
                      : null,

                  child: Opacity(
                    opacity: _hasChanges ? 1.0 : 0.2,
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Save Changes",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          color: isDark ? Colors.black : AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 25, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 13,
          color: Color(0xff919AA7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _editableField(
    TextEditingController controller, {
    bool showDivider = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.8,
            indent: 16,
            color: isDark ? const Color(0xff303840) : const Color(0xffCED4DA),
          ),
      ],
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.searchbar
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
      child: Column(children: children),
    );
  }

  Widget _passwordField(
    String hint, {
    required TextEditingController controller,
    bool showDivider = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            obscureText: true,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xffB0B0B0)),
              border: InputBorder.none,
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.8,
            indent: 16,
            color: isDark ? const Color(0xff303840) : const Color(0xffCED4DA),
          ),
      ],
    );
  }
}
