import 'dart:convert';

class AirQuality {
  final num usEpaIndex;
  final num? carbonMonoxide;
  final num? ozone;
  final num? nitrogenDioxide;
  final num? sulphurDioxide;
  final num? pm2_5;
  final num? pm10;

  AirQuality({
    required this.usEpaIndex,
    this.carbonMonoxide,
    this.ozone,
    this.nitrogenDioxide,
    this.sulphurDioxide,
    this.pm2_5,
    this.pm10,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? airQualityData = json['air_quality'];
    return AirQuality(
      usEpaIndex: airQualityData?['us-epa-index'] ?? 0,
      carbonMonoxide: airQualityData?['co'],
      ozone: airQualityData?['o3'],
      nitrogenDioxide: airQualityData?['no2'],
      sulphurDioxide: airQualityData?['so2'],
      pm2_5: airQualityData?['pm2_5'],
      pm10: airQualityData?['pm10'],
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'us-epa-index': usEpaIndex,
      'co': carbonMonoxide,
      'o3': ozone,
      'no2': nitrogenDioxide,
      'so2': sulphurDioxide,
      'pm2_5': pm2_5,
      'pm10': pm10,
    };
  }

  factory AirQuality.fromDatabaseMap(Map<String, dynamic> map) {
    return AirQuality(
      usEpaIndex: map['us-epa-index'],
      carbonMonoxide: map['co'],
      ozone: map['o3'],
      nitrogenDioxide: map['no2'],
      sulphurDioxide: map['so2'],
      pm2_5: map['pm2_5'],
      pm10: map['pm10'],
    );
  }
}
