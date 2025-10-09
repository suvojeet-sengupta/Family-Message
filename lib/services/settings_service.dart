import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode/jsonDecode

import '../constants/app_constants.dart';
import '../constants/detail_card_constants.dart'; // New import

// New class to hold card type and its visibility
class CustomizableDetailCard {
  final DetailCardType cardType;
  bool isVisible;

  CustomizableDetailCard({required this.cardType, this.isVisible = true});

  Map<String, dynamic> toJson() {
    return {
      'cardType': cardType.toJson(),
      'isVisible': isVisible,
    };
  }

  factory CustomizableDetailCard.fromJson(Map<String, dynamic> json) {
    return CustomizableDetailCard(
      cardType: DetailCardType.fromJson(json['cardType']),
      isVisible: json['isVisible'],
    );
  }
}

class SettingsService with ChangeNotifier {
  bool _useFahrenheit = false;
  List<CustomizableDetailCard> _detailCardPreferences = []; // New field

  bool get useFahrenheit => _useFahrenheit;
  List<CustomizableDetailCard> get detailCardPreferences => _detailCardPreferences; // New getter

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useFahrenheit = prefs.getBool(AppConstants.isFahrenheitKey) ?? false;

    // Load detail card preferences
    final String? cardsJson = prefs.getString(detailCardPreferencesKey);
    if (cardsJson != null) {
      final List<dynamic> decoded = jsonDecode(cardsJson);
      _detailCardPreferences = decoded.map((e) => CustomizableDetailCard.fromJson(e)).toList();

      // Ensure all default cards are present, add new ones if any
      for (var defaultCard in defaultDetailCards) {
        if (!_detailCardPreferences.any((card) => card.cardType.id == defaultCard.id)) {
          _detailCardPreferences.add(CustomizableDetailCard(cardType: defaultCard));
        }
      }
      // Remove any cards that are no longer in defaultDetailCards
      _detailCardPreferences.retainWhere((card) => defaultDetailCards.any((defaultCard) => defaultCard.id == card.cardType.id));

    } else {
      // If no preferences saved, use default order and visibility
      _detailCardPreferences = defaultDetailCards.map((card) => CustomizableDetailCard(cardType: card)).toList();
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

  // New methods for managing detail cards
  void reorderDetailCards(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final card = _detailCardPreferences.removeAt(oldIndex);
    _detailCardPreferences.insert(newIndex, card);
    _saveDetailCardPreferences();
    notifyListeners();
  }

  void toggleDetailCardVisibility(String cardId, bool isVisible) {
    final index = _detailCardPreferences.indexWhere((card) => card.cardType.id == cardId);
    if (index != -1) {
      _detailCardPreferences[index].isVisible = isVisible;
      _saveDetailCardPreferences();
      notifyListeners();
    }
  }
}
