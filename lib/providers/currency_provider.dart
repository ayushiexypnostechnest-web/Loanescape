import 'package:flutter/material.dart';
import 'package:loan_app/models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _code = "INR";
  String _symbol = "₹";

  String get code => _code;
  String get symbol => _symbol;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString('selected_currency_code') ?? "INR";
    _symbol = prefs.getString('selected_currency_symbol') ?? "₹";
    notifyListeners();
  }

  Future<void> setCurrency(Currency currency) async {
    _code = currency.code;
    _symbol = currency.symbol;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency_code', currency.code);
    await prefs.setString('selected_currency_symbol', currency.symbol);

    notifyListeners();
  }
}
