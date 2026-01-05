class Currency {
  final String name;
  final String code;
  final String symbol;

  Currency({required this.name, required this.code, required this.symbol});

 factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      name: json['name'] as String,
      code: json['code'] as String,
      symbol: json['symbol'] as String? ?? '',
    );
  }


  String get section => name[0].toUpperCase();
}
