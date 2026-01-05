import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loan_app/models/currency.dart';
import 'package:loan_app/providers/currency_provider.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  Currency? getSelectedCurrency(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();

    for (final c in allCurrencies) {
      if (c.code == provider.code) {
        return c;
      }
    }
    return null;
  }

  List<Currency> allCurrencies = [];
  List<Currency> filteredCurrencies = [];
  Currency? selectedCurrency;

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  Future<void> loadCurrencies() async {
    final data = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/currencies.json');
    final List list = json.decode(data);
    allCurrencies = list.map((e) => Currency.fromJson(e)).toList();

    setState(() {
      filteredCurrencies = allCurrencies;
    });
  }

  void onSearch(String value) {
    setState(() {
      filteredCurrencies = allCurrencies.where((c) {
        return c.name.toLowerCase().contains(value.toLowerCase()) ||
            c.code.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  Map<String, List<Currency>> groupedCurrencies(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();

    final map = <String, List<Currency>>{};
    for (var c in filteredCurrencies) {
      if (c.code == provider.code) continue;
      map.putIfAbsent(c.section, () => []).add(c);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final selected = getSelectedCurrency(context);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 160,
                left: 10,
                right: 10,
                bottom: 100,
              ),
              child: Column(
                children: [
                  if (selected != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("Selected"),
                        _sectionCard([
                          _profileTile(selected, showDivider: false),
                        ]),
                      ],
                    ),

                  ...groupedCurrencies(context).entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(entry.key),
                        _sectionCard(
                          entry.value
                              .asMap()
                              .entries
                              .map(
                                (e) => _profileTile(
                                  e.value,
                                  showDivider: e.key != entry.value.length - 1,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          Material(
            color: (Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.scaffold.withOpacity(0.5)
                : AppColors.scaffold.withOpacity(0.5)),
            shadowColor: Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.shadow
                : AppColors.shadow,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: Container(
                  height: MediaQuery.of(context).padding.top + 120,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 18,
                    right: 18,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppDarkColors.scaffold.withOpacity(0.5)
                        : AppColors.scaffold.withOpacity(0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
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
                                    fontFamily: 'Lato',
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
                          Text(
                            "Currency",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppDarkColors.white
                                  : AppColors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppDarkColors.searchbar
                              : AppColors.inputBg,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            Icon(
                              Icons.search,
                              size: 20,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppDarkColors.textMuted
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: Colors.black54,
                                  onChanged: onSearch,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search your currency",
                                    hintStyle: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppDarkColors.textMuted
                                          : AppColors.textMuted,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 13,
          color: Color(0xff919AA7),
          fontWeight: FontWeight.w500,
        ),
      ),
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

  Widget _profileTile(Currency currency, {bool showDivider = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final provider = context.watch<CurrencyProvider>();
    final bool isSelected = provider.code == currency.code;

    return InkWell(
      onTap: () {
        context.read<CurrencyProvider>().setCurrency(currency);
        Navigator.pop(context);
      },

      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Text(
                    currency.symbol,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xff001230),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${currency.name} (${currency.code})",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Lato',
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isDark
                          ? Colors.white
                          : isSelected
                          ? const Color(0xff001230)
                          : Colors.black,
                    ),
                  ),
                  Spacer(),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                thickness: 0.8,
                indent: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xff303840)
                    : const Color(0xffCED4DA),
              ),
          ],
        ),
      ),
    );
  }
}
