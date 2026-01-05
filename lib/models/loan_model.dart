class LoanModel {
  String name;
  String? type;
  double amount;
  double rate;
  String emi;
  String startMonthYear;
  String durationYears;
  int paidEmi;
  bool reminder;
  List<Map<String, dynamic>> rateChanges;
  final String createdAt;

  LoanModel({
    required this.name,
    this.type,
    required this.amount,
    required this.rate,
    required this.emi,
    required this.startMonthYear,
    required this.durationYears,
    required this.paidEmi,
    required this.reminder,
    required this.rateChanges,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "amount": amount,
      "rate": rate,
      "emi": emi,
      "startMonthYear": startMonthYear,
      "durationYears": durationYears,
      "paidEmi": paidEmi,
      "reminder": reminder,
      "rateChanges": rateChanges,
      "createdAt": createdAt,
    };
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      name: json["name"] ?? "",
      type: json["type"],
      amount: (json["amount"] ?? 0).toDouble(),
      rate: (json["rate"] ?? 0).toDouble(),
      emi: json["emi"]?.toString() ?? "",
      startMonthYear: json["startMonthYear"] ?? "",
      durationYears: json["durationYears"]?.toString() ?? "",
      paidEmi: json["paidEmi"] ?? 0,
      reminder: json["reminder"] ?? false,
      rateChanges: List<Map<String, dynamic>>.from(json["rateChanges"] ?? []),

      createdAt: json["createdAt"] ?? DateTime.now().toIso8601String(),
    );
  }
}
