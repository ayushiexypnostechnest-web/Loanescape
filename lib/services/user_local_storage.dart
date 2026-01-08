import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  static Future<void> saveUser({
    required String name,
    required String email,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("email", email);

    if (imagePath != null) {
      await prefs.setString("profile_image", imagePath);
    }
  }

  static Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString("name"),
      "email": prefs.getString("email"),
      "profile_image": prefs.getString("profile_image"),
    };
  }
}
