import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:number_pad_keyboard/number_pad_keyboard.dart';

import 'package:loan_app/theme/app_colors.dart';
import '../../data/loantype_data.dart';
import '../../models/loan_model.dart';
import '../../utils/loan_calculator.dart';

class AddEditLoanSheet {
  static void open({
    required BuildContext context,
    int? index,
    required List<LoanModel> loans,
    required Function(LoanModel loan) onSave,
    required Function(int index, LoanModel loan) onUpdate,
  }) {
    final TextEditingController loanName = TextEditingController();
    final TextEditingController loanAmount = TextEditingController();
    final TextEditingController interestRate = TextEditingController();
    final TextEditingController monthlyEmi = TextEditingController();
    final TextEditingController startMonthYear = TextEditingController();
    final TextEditingController durationYears = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final loanNameFocus = FocusNode();
    final loanTypeFocus = FocusNode();
    final startMonthYearFocus = FocusNode();
    final loanAmountFocus = FocusNode();
    final interestRateFocus = FocusNode();
    final durationFocus = FocusNode();
    // (removed unused local flags)

    bool validateName = true;
    bool validateType = true;
    bool validateAmount = true;
    bool validateRate = true;
    bool validateDuration = true;
    bool validateStartDate = true;
    String? selectedLoanType;
    String? selectedLoanIcon;

    bool emiReminder = false;
    int paidEmiValue = 0;

    if (index != null) {
      paidEmiValue = loans[index].paidEmi;
    }

    List<Map<String, dynamic>> rateChanges = [];

    if (index != null) {
      final loan = loans[index];
      loanName.text = loan.name;
      loanAmount.text = loan.amount.toString();
      interestRate.text = loan.rate.toString();
      monthlyEmi.text = loan.emi;
      startMonthYear.text = loan.startMonthYear;
      durationYears.text = loan.durationYears;
      selectedLoanType = loan.type;
      emiReminder = loan.reminder;
      rateChanges = List<Map<String, dynamic>>.from(loan.rateChanges);
    }

    showModalBottomSheet(
      isDismissible: true,
      enableDrag: false,
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final ScrollController scrollController = ScrollController();
              void recalculateEmi() {
                final principal =
                    double.tryParse(loanAmount.text.replaceAll(',', '')) ?? 0;
                final years = int.tryParse(durationYears.text) ?? 0;

                if (principal <= 0 || years <= 0) {
                  setModalState(() {
                    monthlyEmi.text = '';
                  });
                  return;
                }

                final loanMap = {
                  "rate": interestRate.text,
                  "rateChanges": rateChanges,
                };

                final rate = LoanCalculator.getCurrentRate(loanMap);

                final emi = LoanCalculator.calculateEmi(
                  principal: principal,
                  annualRate: rate,
                  months: years * 12,
                );

                setModalState(() {
                  monthlyEmi.text = emi.toStringAsFixed(2);
                });
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppDarkColors.white
                                        : AppColors.black,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),

                            Center(
                              child: Text(
                                index != null ? "Edit Loan" : "Add New Loan",
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        buildLabel("Loan Name"),
                        buildInput(
                          context,
                          loanName,
                          "Enter Loan Name",
                          focusNode: loanNameFocus,
                          errorText: validateName
                              ? null
                              : "Do not enter any special charaters or numbers",
                          onChanged: (v) {
                            setModalState(() {
                              // Allow only letters and spaces, no numbers or special chars
                              validateName =
                                  RegExp(r'^[a-zA-Z ]+$').hasMatch(v) &&
                                  v.isNotEmpty;
                            });
                          },
                        ),

                        if (index == null) ...[
                          buildLabel("Loan Type"),
                          Focus(
                            focusNode: loanTypeFocus,
                            onKey: (node, event) {
                              if (event is RawKeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.tab) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(loanAmountFocus);
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container(
                              height: 52,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 14,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppDarkColors.searchbar
                                    : AppColors.inputBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PopupMenuButton<String>(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.black
                                    : AppColors.white,
                                elevation: 6,
                                constraints: const BoxConstraints(
                                  minWidth: 280,
                                  maxWidth: 280,
                                ),
                                offset: const Offset(0, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  final selectedItem = loanTypes.firstWhere(
                                    (e) => e["title"] == value,
                                  );

                                  setModalState(() {
                                    selectedLoanType = value;
                                    selectedLoanIcon = selectedItem["icon"];
                                    validateType = true;
                                  });

                                  FocusScope.of(
                                    context,
                                  ).requestFocus(loanAmountFocus);
                                },

                                itemBuilder: (context) {
                                  return loanTypes.map((item) {
                                    return PopupMenuItem<String>(
                                      value: item["title"],
                                      height: 48,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item["title"]!,
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 14,
                                            ),
                                          ),
                                          SvgPicture.asset(
                                            item["icon"]!,
                                            width: 20,
                                            height: 20,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (selectedLoanIcon != null)
                                          SvgPicture.asset(
                                            selectedLoanIcon!,
                                            width: 20,
                                            height: 20,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        if (selectedLoanIcon != null)
                                          const SizedBox(width: 10),
                                        Text(
                                          selectedLoanType ??
                                              "Select Your Loan Type",
                                          style: TextStyle(
                                            fontSize: selectedLoanType == null
                                                ? 12
                                                : 14,
                                            fontFamily: 'Lato',
                                            color: selectedLoanType == null
                                                ? const Color(0xff797979)
                                                : Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!validateType)
                            Text(
                              "Loan type is required",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontFamily: 'Lato',
                              ),
                            ),
                        ],

                        buildLabel("Loan Amount"),
                        buildInput(
                          context,
                          loanAmount,
                          "Enter Loan Amount",
                          readOnly: Platform.isIOS,
                          focusNode: loanAmountFocus,
                          nextFocus: interestRateFocus,
                          errorText: validateAmount
                              ? null
                              : "Enter a valid loan amount",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            MoneyInputFormatter(
                              thousandSeparator: ThousandSeparator.Comma,
                              mantissaLength: 0,
                            ),
                          ],
                          onTap: Platform.isIOS
                              ? () {
                                  openIOSNumberPad(
                                    context: context,
                                    controller: loanAmount,
                                    nextFocus: interestRateFocus,

                                    onChanged: () {
                                      recalculateEmi();
                                    },
                                  );
                                }
                              : null,
                          onChanged: (v) {
                            loanAmount.text = v;

                            recalculateEmi();
                          },
                        ),

                        (index == null)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel("Interest Rate"),
                                  buildInput(
                                    context,
                                    interestRate,
                                    "Enter Interest Rate",
                                    readOnly: Platform.isIOS,
                                    focusNode: interestRateFocus,
                                    nextFocus: startMonthYearFocus,

                                    errorText: validateRate
                                        ? null
                                        : "Enter valid interest rate",

                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),

                                    onTap: Platform.isIOS
                                        ? () {
                                            openIOSNumberPad(
                                              context: context,
                                              controller: interestRate,
                                              nextFocus: startMonthYearFocus,

                                              onChanged: () {
                                                final v = interestRate.text;

                                                final isValid = RegExp(
                                                  r'^\d{0,2}(\.\d{0,2})?$',
                                                ).hasMatch(v);

                                                setModalState(() {
                                                  validateRate =
                                                      v.isNotEmpty && isValid;
                                                });

                                                recalculateEmi();
                                              },
                                            );
                                          }
                                        : null,

                                    onChanged: (v) {
                                      final isValid = RegExp(
                                        r'^\d{0,2}(\.\d{0,2})?$',
                                      ).hasMatch(v);

                                      setModalState(() {
                                        validateRate = v.isNotEmpty && isValid;
                                      });

                                      recalculateEmi();
                                    },

                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.percent,
                                        size: 20,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppDarkColors.white
                                            : AppColors.black,
                                      ),
                                    ),

                                    textInputAction: TextInputAction.next,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel("Interest Rate Changes"),

                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 15),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppDarkColors.searchbar
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        if (rateChanges.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              "No Rate Changes Added Yet",
                                              style: TextStyle(
                                                fontFamily: 'Lato',
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ...rateChanges.map((change) {
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 1,
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 4,
                                                  ),
                                              title: Text(
                                                "${change['monthYear']} → ${change['rate']}%",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red.shade400,
                                                ),
                                                onPressed: () {
                                                  setModalState(() {
                                                    rateChanges.remove(change);
                                                  });
                                                  recalculateEmi();
                                                },
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 45,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.add),
                                            label: const Text(
                                              "Add Rate Change",
                                            ),
                                            onPressed: () async {
                                              TextEditingController rateC =
                                                  TextEditingController();
                                              TextEditingController monthYearC =
                                                  TextEditingController();
                                              final FocusNode rateFocus =
                                                  FocusNode();
                                              final FocusNode dummyNextFocus =
                                                  FocusNode();

                                              bool showRateError = false;
                                              bool showMonthYearError = false;

                                              await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder: (context, setDialogState) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          "Add Rate Change",
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextField(
                                                              controller: rateC,
                                                              focusNode:
                                                                  rateFocus,
                                                              readOnly: Platform
                                                                  .isIOS,
                                                              keyboardType:
                                                                  const TextInputType.numberWithOptions(
                                                                    decimal:
                                                                        true,
                                                                  ),
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter.allow(
                                                                  RegExp(
                                                                    r'^\d{0,2}(\.\d{0,2})?$',
                                                                  ),
                                                                ),
                                                              ],
                                                              decoration:
                                                                  inputDecoration(
                                                                    "Enter New Rate",
                                                                    suffix: Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(
                                                                            right:
                                                                                8,
                                                                          ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .percent,
                                                                        size:
                                                                            20,
                                                                        color:
                                                                            Theme.of(
                                                                                  context,
                                                                                ).brightness ==
                                                                                Brightness.dark
                                                                            ? AppDarkColors.white
                                                                            : AppColors.black,
                                                                      ),
                                                                    ),
                                                                  ).copyWith(
                                                                    errorText:
                                                                        showRateError
                                                                        ? "Enter a valid rate"
                                                                        : null,
                                                                  ),

                                                              // ANDROID → normal keyboard
                                                              onChanged:
                                                                  Platform.isIOS
                                                                  ? null
                                                                  : (v) {
                                                                      final isValid =
                                                                          RegExp(
                                                                            r'^\d{0,2}(\.\d{0,2})?$',
                                                                          ).hasMatch(
                                                                            v,
                                                                          );

                                                                      setDialogState(() {
                                                                        showRateError =
                                                                            v.isEmpty ||
                                                                            !isValid;
                                                                      });
                                                                    },

                                                              // iOS → custom number pad
                                                              onTap:
                                                                  Platform.isIOS
                                                                  ? () {
                                                                      openIOSNumberPad(
                                                                        context:
                                                                            context,
                                                                        controller:
                                                                            rateC,
                                                                        nextFocus:
                                                                            dummyNextFocus,
                                                                        onChanged: () {
                                                                          final v = rateC
                                                                              .text
                                                                              .trim();
                                                                          final isValid = RegExp(
                                                                            r'^\d{0,2}(\.\d{0,2})?$',
                                                                          ).hasMatch(v);

                                                                          setDialogState(() {
                                                                            showRateError =
                                                                                v.isEmpty ||
                                                                                !isValid;
                                                                          });
                                                                        },
                                                                      );
                                                                    }
                                                                  : null,
                                                            ),

                                                            const SizedBox(
                                                              height: 12,
                                                            ),

                                                            TextField(
                                                              controller:
                                                                  monthYearC,
                                                              readOnly: true,
                                                              decoration:
                                                                  inputDecoration(
                                                                    "Select Month/Year",
                                                                    suffix: const Icon(
                                                                      Icons
                                                                          .calendar_today,
                                                                    ),
                                                                  ).copyWith(
                                                                    errorText:
                                                                        showMonthYearError
                                                                        ? "Select a month/year"
                                                                        : null,
                                                                  ),
                                                              onTap: () async {
                                                                await pickMonthYear(
                                                                  context:
                                                                      context,
                                                                  loanStart:
                                                                      startMonthYear
                                                                          .text,
                                                                  duration:
                                                                      durationYears
                                                                          .text,
                                                                  controller:
                                                                      monthYearC,
                                                                  onPicked: (value) {
                                                                    setDialogState(() {
                                                                      monthYearC
                                                                              .text =
                                                                          value;
                                                                      showMonthYearError =
                                                                          false;
                                                                    });
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                ),
                                                            child: const Text(
                                                              "Cancel",
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              final rateText =
                                                                  rateC.text
                                                                      .trim();
                                                              final monthYearText =
                                                                  monthYearC
                                                                      .text
                                                                      .trim();

                                                              setDialogState(() {
                                                                showRateError =
                                                                    rateText
                                                                        .isEmpty ||
                                                                    double.tryParse(
                                                                          rateText,
                                                                        ) ==
                                                                        null;
                                                                showMonthYearError =
                                                                    monthYearText
                                                                        .isEmpty;
                                                              });

                                                              if (showRateError ||
                                                                  showMonthYearError)
                                                                return;

                                                              bool isDuplicate =
                                                                  rateChanges.any(
                                                                    (element) =>
                                                                        element['monthYear'] ==
                                                                        monthYearText,
                                                                  );
                                                              if (isDuplicate) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                      "This Month/Year already exists.",
                                                                    ),
                                                                  ),
                                                                );
                                                                return;
                                                              }

                                                              // Add rate change
                                                              setModalState(() {
                                                                rateChanges.add({
                                                                  "monthYear":
                                                                      monthYearText,
                                                                  "rate":
                                                                      double.parse(
                                                                        rateText,
                                                                      ),
                                                                });
                                                              });

                                                              recalculateEmi();
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: const Text(
                                                              "Add",
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        if (index == null) ...[
                          buildLabel("Loan Starting Month/Year"),
                          buildInput(
                            context,
                            startMonthYear,
                            "DD/MM/YYYY",
                            nextFocus: durationFocus,
                            errorText: validateStartDate
                                ? null
                                : "Start date is required",
                            textInputAction: TextInputAction.next,
                            readOnly: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppDarkColors.white
                                    : AppColors.black,
                              ),
                            ),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1970),
                                lastDate: DateTime.now(),
                                helpText: "Select Loan Start Date",
                                cancelText: "CANCEL",
                                confirmText: "SELECT",
                                builder: (context, child) {
                                  final isDark =
                                      Theme.of(context).brightness ==
                                      Brightness.dark;
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      dialogTheme: DialogThemeData(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        backgroundColor: AppDarkColors.scaffold,
                                      ),

                                      colorScheme: isDark
                                          ? const ColorScheme.dark(
                                              primary: Color(0xff115CD4),
                                              onPrimary: Colors.white,
                                              surface: AppDarkColors.scaffold,
                                              onSurface: Colors.white,
                                            )
                                          : const ColorScheme.light(
                                              primary: AppColors.primary,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black,
                                            ),

                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: isDark
                                              ? Colors.white
                                              : AppColors.primary,
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      highlightColor: AppColors.primary
                                          .withOpacity(0.2),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (picked != null) {
                                setModalState(() {
                                  startMonthYear.text =
                                      "${picked.day.toString().padLeft(2, '0')}/"
                                      "${picked.month.toString().padLeft(2, '0')}/"
                                      "${picked.year}";
                                });
                                FocusScope.of(
                                  context,
                                ).requestFocus(durationFocus);
                              }
                            },
                          ),
                        ],

                        buildLabel("Loan Duration (Years)"),
                        buildInput(
                          context,
                          durationYears,
                          "Enter Duration in Years",

                          errorText: validateDuration
                              ? null
                              : "Enter valid duration (1–50 years)",

                          focusNode: durationFocus,

                          readOnly: Platform.isIOS,
                          keyboardType: TextInputType.number,

                          onTap: Platform.isIOS
                              ? () {
                                  openIOSNumberPad(
                                    context: context,
                                    controller: durationYears,
                                    nextFocus: interestRateFocus,

                                    onChanged: () {
                                      recalculateEmi();
                                    },
                                  );
                                }
                              : null,

                          onChanged: (v) {
                            final years = int.tryParse(v) ?? 0;

                            setModalState(() {
                              validateDuration = years >= 1 && years <= 50;
                            });

                            recalculateEmi();
                          },
                        ),

                        buildLabel("Monthly EMI"),
                        buildInput(
                          context,
                          monthlyEmi,
                          "Calculated EMI",
                          readOnly: true,
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 12,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppDarkColors.white
                                    : AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  validateName =
                                      loanName.text.isNotEmpty &&
                                      RegExp(
                                        r'^[a-zA-Z ]+$',
                                      ).hasMatch(loanName.text);

                                  validateAmount = loanAmount.text.isNotEmpty;
                                  validateRate =
                                      interestRate.text.isNotEmpty &&
                                      RegExp(
                                        r'^\d{0,2}(\.\d{0,2})?$',
                                      ).hasMatch(interestRate.text);

                                  final years =
                                      int.tryParse(durationYears.text) ?? 0;
                                  validateDuration = years >= 1 && years <= 50;

                                  if (index == null) {
                                    validateStartDate =
                                        startMonthYear.text.isNotEmpty;
                                    validateType = selectedLoanType != null;
                                  }
                                });

                                if (!validateName ||
                                    !validateAmount ||
                                    !validateRate ||
                                    !validateDuration ||
                                    (index == null &&
                                        (!validateStartDate ||
                                            !validateType))) {
                                  return;
                                }

                                String cleanAmount = loanAmount.text.replaceAll(
                                  RegExp(r'[^0-9.]'),
                                  '',
                                );
                                double principal =
                                    double.tryParse(cleanAmount) ?? 0;

                                double rateValue =
                                    double.tryParse(interestRate.text) ?? 0;

                                double rate = LoanCalculator.getCurrentRate({
                                  "rate": rateValue,
                                  "rateChanges": rateChanges,
                                });

                                int duration =
                                    int.tryParse(durationYears.text) ?? 0;
                                int months = max(1, duration * 12);

                                double emi = LoanCalculator.calculateEmi(
                                  principal: principal,
                                  annualRate: rate,
                                  months: months,
                                );

                                final loanModel = LoanModel(
                                  name: loanName.text,
                                  type: selectedLoanType ?? "Other",
                                  amount: principal,
                                  rate: rate,
                                  emi: emi.toStringAsFixed(2),
                                  startMonthYear: startMonthYear.text,
                                  durationYears: durationYears.text,
                                  paidEmi: paidEmiValue,
                                  reminder: emiReminder,
                                  rateChanges: rateChanges,
                                  createdAt: DateTime.now().toIso8601String(),
                                );

                                if (index != null) {
                                  onUpdate(index, loanModel);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Loan Updated Sucessfully",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppDarkColors.primary
                                          : Color(0xff5A7863),

                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  onSave(loanModel);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Loan Saved Sucessfully"),
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppDarkColors.primary
                                          : AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }

                                Navigator.pop(context);
                              },

                              child: Text(
                                index != null ? "Update" : "Save",
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.black
                                      : AppColors.white,
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
              );
            },
          ),
        );
      },
    );
  }
}

InputDecoration inputDecoration(String hint, {Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    suffixIcon: suffix,
  );
}

void openIOSNumberPad({
  required BuildContext context,
  required TextEditingController controller,
  required FocusNode nextFocus,
  VoidCallback? onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final rootContext = context;

  FocusScope.of(context).unfocus();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (_, setState) {
          void _update(String value) {
            controller.text = value;
            onChanged?.call();
          }

          return Container(
            height: 340,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                Text(
                  controller.text.isEmpty ? "0" : controller.text,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const Divider(height: 20),

                Expanded(
                  child: NumberPadKeyboard(
                    backgroundColor: Colors.transparent,

                    addDigit: (digit) {
                      if (digit == '.') return;

                      final raw = controller.text.replaceAll(RegExp(r'\D'), '');
                      final updated = raw + digit.toString();

                      final formatter = MoneyInputFormatter(
                        thousandSeparator: ThousandSeparator.Comma,
                        mantissaLength: 0,
                      );

                      final formatted = formatter.formatEditUpdate(
                        TextEditingValue(text: raw),
                        TextEditingValue(text: updated),
                      );

                      setState(() => _update(formatted.text));
                    },

                    backspace: () {
                      if (controller.text.isNotEmpty) {
                        setState(
                          () => _update(
                            controller.text.substring(
                              0,
                              controller.text.length - 1,
                            ),
                          ),
                        );
                      }
                    },

                    onEnter: () {
                      Navigator.pop(sheetContext);
                      Future.delayed(
                        const Duration(milliseconds: 150),
                        () =>
                            FocusScope.of(rootContext).requestFocus(nextFocus),
                      );
                    },

                    numberStyle: TextStyle(
                      fontSize: 26,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    deleteIcon: Icon(
                      Icons.backspace_outlined,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    enterButtonText: 'Done',
                    enterButtonTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget buildInput(
  BuildContext context,
  TextEditingController controller,
  String hint, {
  bool readOnly = false,
  String? errorText,
  ValueChanged<String>? onChanged,
  VoidCallback? onTap,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
  String? suffixText,
  Widget? suffixIcon,
  FocusNode? focusNode,
  FocusNode? nextFocus,
  TextInputAction? textInputAction,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final hasError = errorText != null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 52,
        margin: EdgeInsets.only(bottom: hasError ? 4 : 10),
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.searchbar : AppColors.inputBg,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.only(left: 10),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          readOnly: readOnly || onTap != null,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: (_) => nextFocus != null
              ? FocusScope.of(context).requestFocus(nextFocus)
              : FocusScope.of(context).unfocus(),
          cursorColor: isDark ? AppDarkColors.white : AppColors.black,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.only(top: 10),
            hintStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Lato',
              color: Color(0xff797979),
            ),
            border: InputBorder.none,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12),
              child:
                  suffixIcon ??
                  (suffixText == null
                      ? null
                      : Center(
                          child: Text(
                            suffixText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Lato',
                              color: Color(0xff797979),
                            ),
                          ),
                        )),
            ),
          ),
        ),
      ),
      if (hasError)
        Text(
          errorText!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 11,
            fontFamily: 'Lato',
          ),
        ),
    ],
  );
}

Widget buildLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontFamily: 'Lato',
      color: Color(0xff495057),
    ),
  ),
);

Future<void> pickMonthYear({
  required BuildContext context,
  required String loanStart,
  required String duration,
  required TextEditingController controller,
  Function(String)? onPicked,
}) async {
  final startParts = loanStart.split("/");
  int startYear = int.tryParse(startParts[2]) ?? DateTime.now().year;
  int durationYears = int.tryParse(duration) ?? 0;
  final endYear = startYear + durationYears - 1;
  final yearList = List.generate(endYear - startYear + 1, (i) => startYear + i);

  int selectedMonth = 1;
  int selectedYear = startYear;

  if (controller.text.isNotEmpty && controller.text.contains("/")) {
    final parts = controller.text.split("/");
    if (parts.length == 2) {
      selectedMonth = int.tryParse(parts[0]) ?? 1;
      selectedYear = int.tryParse(parts[1]) ?? startYear;
    }
  }

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Select Month & Year"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    isDense: true,
                    menuMaxHeight: 200,
                    decoration: _dropdownDecoration(context),

                    items: List.generate(12, (i) => i + 1)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.toString().padLeft(2, '0')),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedMonth = v!),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    isDense: true,
                    menuMaxHeight: 200,
                    decoration: _dropdownDecoration(context),

                    items: yearList
                        .map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text(y.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedYear = v!),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final value =
                      "${selectedMonth.toString().padLeft(2, '0')}/$selectedYear";
                  controller.text = value;
                  onPicked?.call(value);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}

InputDecoration _dropdownDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? Colors.white : Colors.black,
        width: 1.5,
      ),
    ),
  );
}
