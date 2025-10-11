import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode/jsonDecode

import '../constants/app_constants.dart';
import '../constants/detail_card_constants.dart'; // New import
import 'package:flutter/material.dart'; // For ThemeMode

// Enums for unit preferences
enum TemperatureUnit { celsius, fahrenheit }
enum WindSpeedUnit { kph, mph, ms } // Kilometers per hour, Miles per hour, Meters per second
enum PressureUnit { hPa, inHg, mmHg } // Hectopascals, Inches of Mercury, Millimeters of Mercury

// New class to hold card type and its visibility
class CustomizableDetailCard {
  final String cardTypeId; // Store only the ID
  bool isVisible;

  CustomizableDetailCard({required this.cardTypeId, this.isVisible = true});

  Map<String, dynamic> toJson() {
    return {
      'cardTypeId': cardTypeId, // Store only the ID
      'isVisible': isVisible,
    };
  }

  factory CustomizableDetailCard.fromJson(Map<String, dynamic> json) {
    return CustomizableDetailCard(
      cardTypeId: json['cardTypeId'], // Read only the ID
      isVisible: json['isVisible'],
    );
  }
}

enum ThemePreference { system, light, dark }

class SettingsService with ChangeNotifier {
  List<CustomizableDetailCard> _detailCardPreferences = [];
  ThemePreference _themePreference = ThemePreference.system; // New field

  // New unit preference fields
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  WindSpeedUnit _windSpeedUnit = WindSpeedUnit.kph;
  PressureUnit _pressureUnit = PressureUnit.hPa;

  List<CustomizableDetailCard> get detailCardPreferences => _detailCardPreferences;
  ThemePreference get themePreference => _themePreference; // New getter

  // New unit preference getters
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  WindSpeedUnit get windSpeedUnit => _windSpeedUnit;
  PressureUnit get pressureUnit => _pressureUnit;

  // Convert ThemePreference to ThemeMode for MaterialApp
  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
      default:
        return ThemeMode.system;
    }
  }

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme preference
    final String? themeString = prefs.getString(AppConstants.themePreference);
    if (themeString != null) {
      _themePreference = ThemePreference.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemePreference.system,
      );
    }

    // Load temperature unit
    final String? tempUnitString = prefs.getString(AppConstants.temperatureUnitKey);
    if (tempUnitString != null) {
      _temperatureUnit = TemperatureUnit.values.firstWhere(
        (e) => e.toString() == tempUnitString,
        orElse: () => TemperatureUnit.celsius,
      );
    } else {
      // Backward compatibility for old isFahrenheitKey setting
      _temperatureUnit = (prefs.getBool(AppConstants.isFahrenheitKey) ?? false)
          ? TemperatureUnit.fahrenheit
          : TemperatureUnit.celsius;
    }

    // Load wind speed unit
    final String? windUnitString = prefs.getString(AppConstants.windSpeedUnitKey);
    if (windUnitString != null) {
      _windSpeedUnit = WindSpeedUnit.values.firstWhere(
        (e) => e.toString() == windUnitString,
        orElse: () => WindSpeedUnit.kph,
      );
    }

    // Load pressure unit
    final String? pressureUnitString = prefs.getString(AppConstants.pressureUnitKey);
    if (pressureUnitString != null) {
      _pressureUnit = PressureUnit.values.firstWhere(
        (e) => e.toString() == pressureUnitString,
        orElse: () => PressureUnit.hPa,
      );
    }

    // Load detail card preferences
    final String? cardsJson = prefs.getString(detailCardPreferencesKey);
    if (cardsJson != null) {
      final List<dynamic> decoded = jsonDecode(cardsJson);
      _detailCardPreferences = decoded.map((e) {
        final loadedCard = CustomizableDetailCard.fromJson(e);
        final defaultCard = defaultDetailCards.firstWhere(
          (card) => card.id == loadedCard.cardTypeId,
          orElse: () => throw Exception('Unknown card type ID: ${loadedCard.cardTypeId}'), // Should not happen if defaultDetailCards is consistent
        );
        return CustomizableDetailCard(cardTypeId: defaultCard.id, isVisible: loadedCard.isVisible);
      }).toList();

      // Ensure all default cards are present, add new ones if any
      for (var defaultCard in defaultDetailCards) {
        if (!_detailCardPreferences.any((card) => card.cardTypeId == defaultCard.id)) {
          _detailCardPreferences.add(CustomizableDetailCard(cardTypeId: defaultCard.id));
        }
      }
      // Remove any cards that are no longer in defaultDetailCards
      _detailCardPreferences.retainWhere((card) => defaultDetailCards.any((defaultCard) => defaultCard.id == card.cardTypeId));

    } else {
      // If no preferences saved, use default order and visibility
      _detailCardPreferences = defaultDetailCards.map((card) => CustomizableDetailCard(cardTypeId: card.id)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveDetailCardPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_detailCardPreferences.map((e) => e.toJson()).toList());
    await prefs.setString(detailCardPreferencesKey, encoded);
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    _themePreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themePreference, preference.toString());
    notifyListeners();
  }

  // New setters for unit preferences
  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    _temperatureUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.temperatureUnitKey, unit.toString());
    // Remove old key for backward compatibility
    await prefs.remove(AppConstants.isFahrenheitKey);
    notifyListeners();
  }

  Future<void> setWindSpeedUnit(WindSpeedUnit unit) async {
    _windSpeedUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.windSpeedUnitKey, unit.toString());
    notifyListeners();
  }

  Future<void> setPressureUnit(PressureUnit unit) async {
    _pressureUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.pressureUnitKey, unit.toString());
    notifyListeners();
  }

  // New methods for managing detail cards
  void reorderDetailCards(int oldIndex, int newIndex) {
    // Perform a direct swap
    final temp = _detailCardPreferences[oldIndex];
    _detailCardPreferences[oldIndex] = _detailCardPreferences[newIndex];
    _detailCardPreferences[newIndex] = temp;

    _saveDetailCardPreferences();
    notifyListeners();
  }

  void toggleDetailCardVisibility(String cardId, bool isVisible) {
    final index = _detailCardPreferences.indexWhere((card) => card.cardTypeId == cardId);
    if (index != -1) {
      _detailCardPreferences[index].isVisible = isVisible;
      _saveDetailCardPreferences();
      notifyListeners();
    }
  }
}
