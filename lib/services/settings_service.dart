import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  static const String _isFahrenheitKey = 'isFahrenheit';
  bool _useFahrenheit = false;

  bool get useFahrenheit => _useFahrenheit;

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useFahrenheit = prefs.getBool(_isFahrenheitKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleUnit(bool value) async {
    _useFahrenheit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFahrenheitKey, value);
    notifyListeners();
  }
}
