import 'dart:convert';
import 'dart:math' as math;

/// Represents geographical coordinates with latitude and longitude.
class GeoCoordinates {
  /// Creates a [GeoCoordinates] instance with the given [latitude] and [longitude].
  const GeoCoordinates({required this.latitude, required this.longitude});

  /// Creates a [GeoCoordinates] instance from a JSON map.
  factory GeoCoordinates.fromJson(Map<String, dynamic> json) {
    return GeoCoordinates(
      latitude:
          (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          0.0,
      longitude:
          (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble() ??
          (json['lon'] as num?)?.toDouble() ??
          0.0,
    );
  }

  /// Creates a [GeoCoordinates] from a JSON string.
  factory GeoCoordinates.fromJsonString(String source) =>
      GeoCoordinates.fromJson(json.decode(source) as Map<String, dynamic>);

  /// The latitude in decimal degrees (-90.0 to 90.0).
  final double latitude;

  /// The longitude in decimal degrees (-180.0 to 180.0).
  final double longitude;

  /// Validates whether the coordinates are within valid geographic bounds.
  bool get isValid =>
      latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0;

  /// Calculates the Great-Circle distance in meters to [other] using the Haversine formula.
  double distanceTo(GeoCoordinates other) {
    const double earthRadiusMeters = 6371000.0;
    final double lat1Rad = _toRadians(latitude);
    final double lat2Rad = _toRadians(other.latitude);
    final double deltaLat = _toRadians(other.latitude - latitude);
    final double deltaLon = _toRadians(other.longitude - longitude);

    final double a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Calculates the initial compass bearing in degrees (0° - 360°) towards [other].
  double bearingTo(GeoCoordinates other) {
    final double lat1Rad = _toRadians(latitude);
    final double lat2Rad = _toRadians(other.latitude);
    final double deltaLon = _toRadians(other.longitude - longitude);

    final double y = math.sin(deltaLon) * math.cos(lat2Rad);
    final double x =
        math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLon);

    final double bearingRad = math.atan2(y, x);
    final double bearingDeg = _toDegrees(bearingRad);

    return (bearingDeg + 360) % 360;
  }

  /// Formats the coordinates into Degrees, Minutes, and Seconds (DMS) string.
  ///
  /// Example: `40° 42' 51.4" N, 73° 57' 41.2" W`
  String toDMS() {
    final String latDMS = _formatDMS(latitude, isLatitude: true);
    final String lonDMS = _formatDMS(longitude, isLatitude: false);
    return '$latDMS, $lonDMS';
  }

  static String _formatDMS(double value, {required bool isLatitude}) {
    final String hemisphere =
        isLatitude ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
    final double absVal = value.abs();
    final int degrees = absVal.floor();
    final double minutesDecimal = (absVal - degrees) * 60;
    final int minutes = minutesDecimal.floor();
    final double seconds = (minutesDecimal - minutes) * 60;

    return '$degrees° $minutes\' ${seconds.toStringAsFixed(1)}" $hemisphere';
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);
  static double _toDegrees(double radians) => radians * (180.0 / math.pi);

  /// Creates a copy with optional updated fields.
  GeoCoordinates copyWith({double? latitude, double? longitude}) {
    return GeoCoordinates(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Converts this instance to a map.
  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => toMap();

  /// Converts this instance to a JSON string.
  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is GeoCoordinates &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoCoordinates($latitude, $longitude)';
}
