import 'package:flutter/material.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _openMail() async {
    final subject = Uri.encodeComponent('Loan App Support');
    final body = Uri.encodeComponent(
      'Hello Support Team,\n\n'
      'I am facing an issue related to my loan.\n\n'
      '--------------------------\n'
      'Please let me know the next step.\n'
      'Thank you\n'
      '--------------------------\n',
    );

    final Uri emailUri = Uri.parse(
      'mailto:support@loanapp.com?subject=$subject&body=$body',
    );

    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.primary
                : AppColors.primary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help Center",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.white
                : AppColors.black,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.card
            : AppColors.white,
        surfaceTintColor: Colors.white,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("CONTACT US"),
          _card([
            _tile(
              context: context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "support@loanapp.com",
              onTap: _openMail,
              showDivider: false,
            ),
          ], context),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 25, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Lato',
          color: Color(0xff919AA7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.searchbar
            : AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    bool showDivider = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.black,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppDarkColors.white
                              : AppColors.black,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 13,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppDarkColors.textMuted
                                : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 26,
                  color: Color(0xff919AA7),
                ),
              ],
            ),
          ),
          if (showDivider) const Divider(indent: 54, height: 1, thickness: 0.6),
        ],
      ),
    );
  }
}
