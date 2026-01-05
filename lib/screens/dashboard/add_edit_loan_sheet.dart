import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:number_pad_keyboard/number_pad_keyboard.dart'
    show NumberPadKeyboard;
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
    final _formKey = GlobalKey<FormState>();
    final loanNameFocus = FocusNode();
    final loanTypeFocus = FocusNode();
    final startMonthYearFocus = FocusNode();
    final loanAmountFocus = FocusNode();
    final interestRateFocus = FocusNode();
    final durationFocus = FocusNode();

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

              void calculateEMIForModal() {
                final principal =
                    double.tryParse(loanAmount.text.replaceAll(',', '')) ?? 0;
                final rate = double.tryParse(interestRate.text) ?? 0;
                final years = int.tryParse(durationYears.text) ?? 0;

                if (principal > 0 && rate > 0 && years > 0) {
                  final months = years * 12;
                  final emi = LoanCalculator.calculateEmi(
                    principal: principal,
                    annualRate: rate,
                    months: months,
                  );

                  setModalState(() {
                    monthlyEmi.text = emi.toStringAsFixed(2);
                  });
                } else {
                  setModalState(() {
                    monthlyEmi.text = '';
                  });
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
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
                                    allowDecimal: false,
                                    onChanged: () {
                                      calculateEMIForModal();
                                      recalculateEmi();
                                    },
                                  );
                                }
                              : null,
                          onChanged: (v) {
                            final clean = toNumericString(v);
                            loanAmount.text = v;
                            calculateEMIForModal();
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
                                              allowDecimal: true,
                                              onChanged: () {
                                                calculateEMIForModal();
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

                                      calculateEMIForModal();
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
                                                              readOnly: true,
                                                              decoration: InputDecoration(
                                                                hintText:
                                                                    "Enter New Rate",
                                                                border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                                contentPadding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          10,
                                                                    ),
                                                                suffixIcon: Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        right:
                                                                            8,
                                                                      ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .percent,
                                                                    size: 20,
                                                                    color:
                                                                        Theme.of(
                                                                              context,
                                                                            ).brightness ==
                                                                            Brightness.dark
                                                                        ? AppDarkColors
                                                                              .white
                                                                        : AppColors
                                                                              .black,
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                openIOSNumberPad(
                                                                  context:
                                                                      context,
                                                                  controller:
                                                                      rateC,
                                                                  nextFocus:
                                                                      dummyNextFocus,
                                                                  allowDecimal:
                                                                      true,
                                                                );
                                                              },
                                                            ),

                                                            const SizedBox(
                                                              height: 12,
                                                            ),
                                                            GestureDetector(
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
                                                                    });
                                                                  },
                                                                );
                                                              },

                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          14,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Theme.of(
                                                                            context,
                                                                          ).brightness ==
                                                                          Brightness
                                                                              .dark
                                                                      ? AppDarkColors
                                                                            .searchbar
                                                                      : Colors
                                                                            .grey
                                                                            .shade200,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      monthYearC
                                                                              .text
                                                                              .isEmpty
                                                                          ? "Select Month/Year"
                                                                          : monthYearC.text,
                                                                      style: TextStyle(
                                                                        fontFamily:
                                                                            'Lato',
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            monthYearC.text.isEmpty
                                                                            ? Colors.grey.shade600
                                                                            : Theme.of(
                                                                                    context,
                                                                                  ).brightness ==
                                                                                  Brightness.dark
                                                                            ? Colors.white
                                                                            : Colors.black87,
                                                                      ),
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .calendar_today,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade600,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
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
                                                              if (rateC
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  monthYearC
                                                                      .text
                                                                      .isNotEmpty) {
                                                                setModalState(() {
                                                                  rateChanges.add({
                                                                    "monthYear":
                                                                        monthYearC
                                                                            .text,
                                                                    "rate": double.parse(
                                                                      rateC
                                                                          .text,
                                                                    ),
                                                                  });
                                                                });
                                                              }
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

                              final isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;

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
                                    allowDecimal: false,
                                    onChanged: () {
                                      calculateEMIForModal();
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

                            calculateEMIForModal();
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
                                      backgroundColor: Color(0xff5A7863),
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
                                      content: const Text(
                                        "Loan Saved Sucessfully",
                                      ),
                                      backgroundColor: Color(0xff5A7863),
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

void openIOSNumberPad({
  required BuildContext context,
  required TextEditingController controller,
  required FocusNode nextFocus,
  bool allowDecimal = false,
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
        builder: (context, setSheetState) {
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

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.text.isEmpty ? "0" : controller.text,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: NumberPadKeyboard(
                    backgroundColor: Colors.transparent,

                    addDigit: (digit) {
                      setSheetState(() {
                        if (digit == '.') return; // No decimal for loan amount

                        final raw = controller.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        final updated = raw + digit.toString();

                        final formatter = MoneyInputFormatter(
                          thousandSeparator: ThousandSeparator.Comma,
                          mantissaLength: 0,
                        );

                        final formatted = formatter.formatEditUpdate(
                          TextEditingValue(text: raw),
                          TextEditingValue(text: updated),
                        );

                        controller.value = formatted;
                      });

                      onChanged?.call();
                    },

                    backspace: () {
                      setSheetState(() {
                        if (controller.text.isNotEmpty) {
                          controller.text = controller.text.substring(
                            0,
                            controller.text.length - 1,
                          );
                        }
                      });
                    },

                    onEnter: () {
                      Navigator.pop(sheetContext);

                      Future.delayed(const Duration(milliseconds: 150), () {
                        FocusScope.of(rootContext).requestFocus(nextFocus);
                      });
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
  const double fieldHeight = 52;

  final hasError = errorText != null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: fieldHeight,
        margin: EdgeInsets.only(bottom: hasError ? 4 : 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppDarkColors.searchbar
              : AppColors.inputBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: TextField(
            focusNode: focusNode,
            textInputAction: textInputAction,

            onSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              } else {
                FocusScope.of(context).unfocus();
              }
            },

            cursorColor: Theme.of(context).brightness == Brightness.dark
                ? AppDarkColors.white
                : AppColors.black,
            controller: controller,
            readOnly: readOnly || onTap != null,
            onTap: onTap,
            onChanged: onChanged,
            keyboardType: keyboardType ?? TextInputType.text,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
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

              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),
      ),
      if (hasError)
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 8),
          child: Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontFamily: 'Lato',
            ),
          ),
        ),
    ],
  );
}

Widget buildLabel(String text) {
  const double labelSpacing = 6;

  return Padding(
    padding: const EdgeInsets.only(bottom: labelSpacing),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Lato',
        color: Color(0xff495057),
      ),
    ),
  );
}

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
            title: const Text("Select Month & Year"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (i) => i + 1)
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.toString().padLeft(2, '0')),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedMonth = v!;
                    });
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedYear,
                  items: yearList
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedYear = v!;
                    });
                  },
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
                  if (onPicked != null) onPicked(value);
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

List<int> calculateLoanYears(String start, String durationYears) {
  final startParts = start.split("/");
  int startYear = int.tryParse(startParts[2]) ?? DateTime.now().year;
  int duration = int.tryParse(durationYears) ?? 0;

  final endYear = startYear + duration - 1;

  List<int> years = [];
  for (int y = startYear; y <= endYear; y++) {
    years.add(y);
  }

  return years;
}
