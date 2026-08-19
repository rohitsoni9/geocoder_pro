import 'dart:math' as math;
import 'package:geocoder_pro/src/models/geo_coordinates.dart';

/// Comprehensive utility class for spatial, distance, and geocoding helper functions.
class GeoUtils {
  GeoUtils._();

  /// Earth's mean radius in meters.
  static const double earthRadiusMeters = 6371000.0;

  /// Earth's mean radius in kilometers.
  static const double earthRadiusKm = 6371.0;

  /// Earth's mean radius in miles.
  static const double earthRadiusMiles = 3958.8;

  /// Calculates the Great-Circle distance in meters between two coordinates using the Haversine formula.
  static double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final double lat1Rad = _toRadians(startLatitude);
    final double lat2Rad = _toRadians(endLatitude);
    final double deltaLat = _toRadians(endLatitude - startLatitude);
    final double deltaLon = _toRadians(endLongitude - startLongitude);

    final double a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Calculates the Great-Circle distance in kilometers between two coordinates.
  static double distanceBetweenKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000.0;
  }

  /// Calculates the Great-Circle distance in miles between two coordinates.
  static double distanceBetweenMiles(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return distanceBetweenKm(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) *
        0.621371;
  }

  /// Calculates the initial compass bearing in degrees (0° - 360°) from start to end coordinates.
  static double bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final double lat1Rad = _toRadians(startLatitude);
    final double lat2Rad = _toRadians(endLatitude);
    final double deltaLon = _toRadians(endLongitude - startLongitude);

    final double y = math.sin(deltaLon) * math.cos(lat2Rad);
    final double x =
        math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLon);

    final double bearingRad = math.atan2(y, x);
    final double bearingDeg = _toDegrees(bearingRad);

    return (bearingDeg + 360) % 360;
  }

  /// Checks if [targetLat], [targetLon] is within [radiusInMeters] of [centerLat], [centerLon].
  static bool isWithinRadius({
    required double centerLatitude,
    required double centerLongitude,
    required double targetLatitude,
    required double targetLongitude,
    required double radiusInMeters,
  }) {
    final double distance = distanceBetween(
      centerLatitude,
      centerLongitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= radiusInMeters;
  }

  /// Validates whether the given latitude and longitude are valid coordinates.
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  /// Formats a distance in meters into a human-readable string (e.g. "450 m", "2.5 km", "2.1 mi").
  static String formatDistance(
    double distanceInMeters, {
    bool imperial = false,
  }) {
    if (imperial) {
      final double feet = distanceInMeters * 3.28084;
      if (feet < 1000) {
        return '${feet.toStringAsFixed(0)} ft';
      }
      final double miles = distanceInMeters * 0.000621371;
      final String formattedMiles = _formatNumber(miles, maxDecimals: 2);
      return '$formattedMiles mi';
    } else {
      if (distanceInMeters < 1000) {
        return '${distanceInMeters.toStringAsFixed(0)} m';
      }
      final double km = distanceInMeters / 1000.0;
      final String formattedKm = _formatNumber(km, maxDecimals: 1);
      return '$formattedKm km';
    }
  }

  static String _formatNumber(double value, {required int maxDecimals}) {
    String str = value.toStringAsFixed(maxDecimals);
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }

  /// Formats latitude and longitude coordinates into decimal or DMS notation.
  static String formatCoordinates(
    double latitude,
    double longitude, {
    bool dms = false,
  }) {
    final coords = GeoCoordinates(latitude: latitude, longitude: longitude);
    return dms ? coords.toDMS() : '$latitude, $longitude';
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);
  static double _toDegrees(double radians) => radians * (180.0 / math.pi);
}
