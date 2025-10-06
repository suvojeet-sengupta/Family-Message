import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class SettingsService with ChangeNotifier {
  bool _useFahrenheit = false;

  bool get useFahrenheit => _useFahrenheit;

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useFahrenheit = prefs.getBool(AppConstants.isFahrenheitKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleUnit(bool value) async {
    _useFahrenheit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isFahrenheitKey, value);
    notifyListeners();
  }
}
