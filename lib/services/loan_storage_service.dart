import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loan_model.dart';

class LoanStorageService {
  static const String _key = "loans";
  static List<LoanModel> _cachedLoans = [];

  static Future<List<LoanModel>> loadLoans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList(_key);

    if (storedList == null || storedList.isEmpty) {
      return [];
    }

    return storedList.map((e) => LoanModel.fromJson(jsonDecode(e))).toList();
  }

  static List<LoanModel> getLoans() {
    return _cachedLoans;
  }

  static Future<void> saveAllLoans(List<LoanModel> loans) async {
    _cachedLoans = loans;
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = loans.map((l) => jsonEncode(l.toJson())).toList();

    await prefs.setStringList(_key, data);
  }
}
