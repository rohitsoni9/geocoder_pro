import 'package:geocoder_pro/src/models/geo_data.dart';

/// Abstract contract for all geocoding providers in `geocoder_pro`.
abstract class BaseGeocoder {
  /// Resolves an address string into a single [GeoData] object, or `null` if not found.
  Future<GeoData?> getDataFromAddress(String address, {String? language});

  /// Resolves an address string into a list of matching [GeoData] objects.
  Future<List<GeoData>> getAddressesFromAddress(
    String address, {
    String? language,
  });

  /// Resolves geographical coordinates into a single [GeoData] object, or `null` if not found.
  Future<GeoData?> getDataFromCoordinates({
    required double latitude,
    required double longitude,
    String? language,
  });

  /// Resolves geographical coordinates into a list of matching [GeoData] objects.
  Future<List<GeoData>> getAddressesFromCoordinates({
    required double latitude,
    required double longitude,
    String? language,
  });
}
