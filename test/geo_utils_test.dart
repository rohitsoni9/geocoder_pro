import 'package:flutter_test/flutter_test.dart';
import 'package:geocoder_pro/geocoder_pro.dart';

void main() {
  group('GeoUtils', () {
    test('distanceBetween calculates accurate distances', () {
      // New York to London ~ 5570 km
      const nyLat = 40.7128;
      const nyLon = -74.0060;
      const lonLat = 51.5074;
      const lonLon = -0.1278;

      final distanceM = GeoUtils.distanceBetween(nyLat, nyLon, lonLat, lonLon);
      expect(distanceM, closeTo(5570000, 50000));

      final distanceKm = GeoUtils.distanceBetweenKm(
        nyLat,
        nyLon,
        lonLat,
        lonLon,
      );
      expect(distanceKm, closeTo(5570, 50));

      final distanceMiles = GeoUtils.distanceBetweenMiles(
        nyLat,
        nyLon,
        lonLat,
        lonLon,
      );
      expect(distanceMiles, closeTo(3460, 50));
    });

    test('bearingBetween calculates accurate compass bearings', () {
      // Equator (0,0) to North (10, 0) -> 0 degrees
      final bearingNorth = GeoUtils.bearingBetween(0, 0, 10, 0);
      expect(bearingNorth, closeTo(0, 0.1));

      // Equator (0,0) to East (0, 10) -> 90 degrees
      final bearingEast = GeoUtils.bearingBetween(0, 0, 0, 10);
      expect(bearingEast, closeTo(90, 0.1));

      // Equator (0,0) to South (-10, 0) -> 180 degrees
      final bearingSouth = GeoUtils.bearingBetween(0, 0, -10, 0);
      expect(bearingSouth, closeTo(180, 0.1));

      // Equator (0,0) to West (0, -10) -> 270 degrees
      final bearingWest = GeoUtils.bearingBetween(0, 0, 0, -10);
      expect(bearingWest, closeTo(270, 0.1));
    });

    test('isWithinRadius works correctly', () {
      const centerLat = 37.7749;
      const centerLon = -122.4194;

      // Nearby point (~100m away)
      const nearbyLat = 37.7750;
      const nearbyLon = -122.4195;
      expect(
        GeoUtils.isWithinRadius(
          centerLatitude: centerLat,
          centerLongitude: centerLon,
          targetLatitude: nearbyLat,
          targetLongitude: nearbyLon,
          radiusInMeters: 500,
        ),
        isTrue,
      );

      // Faraway point (Tokyo)
      const tokyoLat = 35.6762;
      const tokyoLon = 139.6503;
      expect(
        GeoUtils.isWithinRadius(
          centerLatitude: centerLat,
          centerLongitude: centerLon,
          targetLatitude: tokyoLat,
          targetLongitude: tokyoLon,
          radiusInMeters: 10000,
        ),
        isFalse,
      );
    });

    test('isValidCoordinates validates boundaries', () {
      expect(GeoUtils.isValidCoordinates(45.0, 90.0), isTrue);
      expect(GeoUtils.isValidCoordinates(-90.0, -180.0), isTrue);
      expect(GeoUtils.isValidCoordinates(90.0, 180.0), isTrue);
      expect(GeoUtils.isValidCoordinates(90.1, 0.0), isFalse);
      expect(GeoUtils.isValidCoordinates(0.0, 180.1), isFalse);
    });

    test('formatDistance formats metric and imperial strings', () {
      expect(GeoUtils.formatDistance(350), '350 m');
      expect(GeoUtils.formatDistance(2500), '2.5 km');
      expect(GeoUtils.formatDistance(15000), '15 km');

      expect(GeoUtils.formatDistance(50, imperial: true), '164 ft');
      expect(GeoUtils.formatDistance(5000, imperial: true), '3.11 mi');
    });

    test('formatCoordinates formats decimal and DMS', () {
      expect(GeoUtils.formatCoordinates(40.7128, -74.0060), '40.7128, -74.006');
      final dms = GeoUtils.formatCoordinates(40.7128, -74.0060, dms: true);
      expect(dms, contains('40°'));
      expect(dms, contains('N'));
      expect(dms, contains('74°'));
      expect(dms, contains('W'));
    });
  });
}
