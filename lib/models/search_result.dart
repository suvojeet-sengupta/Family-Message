class SearchResult {
  final String name;
  final String region;
  final String country;

  SearchResult({
    required this.name,
    required this.region,
    required this.country,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      country: json['country'] ?? '',
    );
  }

  @override
  String toString() {
    return '$name, $region, $country';
  }
}
