import 'dart:math';

class LoanCalculator {
  static double calculateEmi({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    if (annualRate == 0) {
      return principal / months;
    }

    double r = annualRate / 12 / 100;
    double powVal = pow(1 + r, months).toDouble();
    return principal * r * powVal / (powVal - 1);
  }

  static double getCurrentRate(Map<String, dynamic> loan) {
    double rate = double.tryParse(loan["rate"].toString()) ?? 0;
    List changes = loan["rateChanges"] ?? [];

    DateTime now = DateTime.now();

    for (var change in changes) {
      String my = change["monthYear"];
      int m = int.tryParse(my.split("/")[0]) ?? now.month;
      int y = int.tryParse(my.split("/")[1]) ?? now.year;

      DateTime changeDate = DateTime(y, m);
      if (!changeDate.isAfter(DateTime(now.year, now.month))) {
        rate = change["rate"];
      }
    }
    return rate;
  }

  // Calculate next EMI date based on start date string ("dd/MM/yyyy")
  static DateTime getNextEmiDate(String startDateString) {
    final now = DateTime.now();

    if (!startDateString.contains('/')) return now;

    final parts = startDateString.split('/');
    if (parts.length != 3) return now;

    final startDay = int.tryParse(parts[0]) ?? 1;
    final startMonth = int.tryParse(parts[1]) ?? 1;
    final startYear = int.tryParse(parts[2]) ?? now.year;

    DateTime emiDate = DateTime(startYear, startMonth, startDay);

    while (!emiDate.isAfter(now)) {
      int nextMonth = emiDate.month + 1;
      int nextYear = emiDate.year;

      final lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
      final day = startDay <= lastDayOfNextMonth
          ? startDay
          : lastDayOfNextMonth;

      emiDate = DateTime(nextYear, nextMonth, day);
    }

    return emiDate;
  }

  static DateTime getEndDate(DateTime start, int totalMonths) {
    int endMonth = start.month + totalMonths;
    int endYear = start.year + (endMonth - 1) ~/ 12;
    int month = ((endMonth - 1) % 12) + 1;
    int day = min(start.day, DateTime(endYear, month + 1, 0).day);
    return DateTime(endYear, month, day);
  }

  static String formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
