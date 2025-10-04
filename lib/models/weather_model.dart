class Weather {
  final String locationName;
  final double temperature;
  final String condition;
  final String iconUrl;

  Weather({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      locationName: json['location']['name'],
      temperature: json['current']['temp_c'],
      condition: json['current']['condition']['text'],
      iconUrl: 'https:${json['current']['condition']['icon']}',
    );
  }
}
