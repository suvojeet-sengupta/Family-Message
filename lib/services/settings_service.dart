import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _isFahrenheitKey = 'isFahrenheit';

  Future<bool> isFahrenheit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFahrenheitKey) ?? false;
  }

  Future<void> setFahrenheit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFahrenheitKey, value);
  }
}
