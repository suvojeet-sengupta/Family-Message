
class CacheKey {
  final String value;

  CacheKey.fromCity(String city, String? country)
      : value = country != null ? '$city,$country' : city;

  CacheKey.fromCoordinates(double lat, double lon)
      : value = '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';

  @override
  String toString() => value;
}
