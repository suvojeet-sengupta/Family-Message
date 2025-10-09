import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode/jsonDecode

import '../constants/app_constants.dart';
import '../constants/detail_card_constants.dart'; // New import
import 'package:flutter/material.dart'; // For ThemeMode

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
  bool _useFahrenheit = false;
  List<CustomizableDetailCard> _detailCardPreferences = [];
  ThemePreference _themePreference = ThemePreference.system; // New field

  bool get useFahrenheit => _useFahrenheit;
  List<CustomizableDetailCard> get detailCardPreferences => _detailCardPreferences;
  ThemePreference get themePreference => _themePreference; // New getter

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
    _useFahrenheit = prefs.getBool(AppConstants.isFahrenheitKey) ?? false;

    // Load theme preference
    final String? themeString = prefs.getString(AppConstants.themePreference);
    if (themeString != null) {
      _themePreference = ThemePreference.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemePreference.system,
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

  Future<void> toggleUnit(bool value) async {
    _useFahrenheit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isFahrenheitKey, value);
    notifyListeners();
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    _themePreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themePreference, preference.toString());
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
