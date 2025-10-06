import 'dart:convert';

class AirQuality {
  final num usEpaIndex;

  AirQuality({required this.usEpaIndex});

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    return AirQuality(
      usEpaIndex: json['us-epa-index'] ?? 0,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'us-epa-index': usEpaIndex,
    };
  }

  factory AirQuality.fromDatabaseMap(Map<String, dynamic> map) {
    return AirQuality(
      usEpaIndex: map['us-epa-index'],
    );
  }
}
