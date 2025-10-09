import 'package:flutter/material.dart';

class DetailCardType {
  final String id;
  final String title;
  final IconData icon; // Add icon for display in settings

  const DetailCardType({required this.id, required this.title, required this.icon});

  // Factory constructor for creating from JSON (for SharedPreferences)
  factory DetailCardType.fromJson(Map<String, dynamic> json) {
    return DetailCardType(
      id: json['id'],
      title: json['title'],
      icon: IconData(json['iconCodePoint'], fontFamily: json['iconFontFamily']),
    );
  }

  // Convert to JSON (for SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
    };
  }
}

// Default list of detail cards
final List<DetailCardType> defaultDetailCards = [
  const DetailCardType(id: 'precipitation', title: 'Precipitation', icon: Icons.water_drop),
  const DetailCardType(id: 'wind', title: 'Wind', icon: Icons.air),
  const DetailCardType(id: 'pressure', title: 'Pressure', icon: Icons.compress),
  const DetailCardType(id: 'air_quality', title: 'Air Quality', icon: Icons.air_outlined),
  const DetailCardType(id: 'humidity', title: 'Humidity', icon: Icons.water),
  const DetailCardType(id: 'uv_index', title: 'UV Index', icon: Icons.wb_sunny_outlined),
  const DetailCardType(id: 'sunrise_sunset', title: 'Sunrise & Sunset', icon: Icons.brightness_6),
  const DetailCardType(id: 'visibility', title: 'Visibility', icon: Icons.visibility),
  const DetailCardType(id: 'dew_point', title: 'Dew Point', icon: Icons.thermostat_auto),
];

// SharedPreferences key for storing card preferences
const String detailCardPreferencesKey = 'detailCardPreferences';
