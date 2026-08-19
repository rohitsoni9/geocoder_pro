import 'package:geocoder_pro/src/models/geo_data.dart';
import 'package:geocoder_pro/src/providers/base_geocoder.dart';
import 'package:geocoder_pro/src/providers/google_geocoder.dart';
import 'package:geocoder_pro/src/providers/nominatim_geocoder.dart';
import 'package:geocoder_pro/src/utils/geo_utils.dart';
import 'package:http/http.dart' as http;

/// Main entry point for geocoding operations in Flutter.
///
/// Supports both Google Maps Geocoding API and free OpenStreetMap (Nominatim),
/// providing forward and reverse geocoding, spatial calculations, and address details.
class GeocoderPro {
  GeocoderPro._();

  /// Creates a [GoogleGeocoder] instance configured with your Google Maps API key.
  static GoogleGeocoder google({
    required String apiKey,
    http.Client? client,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) {
    return GoogleGeocoder(
      apiKey: apiKey,
      client: client,
      headers: headers,
      timeout: timeout,
    );
  }

  /// Creates a [NominatimGeocoder] instance for free OpenStreetMap geocoding.
  static NominatimGeocoder nominatim({
    String userAgent =
        'GeocoderPro-Flutter/1.1.0 (https://github.com/rohitsoni9/geocoder_pro)',
    http.Client? client,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) {
    return NominatimGeocoder(
      userAgent: userAgent,
      client: client,
      headers: headers,
      timeout: timeout,
    );
  }

  /// Alias for [nominatim] to create an OpenStreetMap geocoder instance.
  static NominatimGeocoder openStreetMap({
    String userAgent =
        'GeocoderPro-Flutter/1.1.0 (https://github.com/rohitsoni9/geocoder_pro)',
    http.Client? client,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) {
    return nominatim(
      userAgent: userAgent,
      client: client,
      headers: headers,
      timeout: timeout,
    );
  }

  // ---------------------------------------------------------------------------
  // Static Convenience Methods (Backward Compatible)
  // ---------------------------------------------------------------------------

  /// Retrieves location data from latitude and longitude coordinates using Google Maps API.
  ///
  /// [latitude] The latitude coordinate.
  /// [longitude] The longitude coordinate.
  /// [googleMapApiKey] Your Google Maps API key.
  /// [language] Optional language code for the results (e.g., 'en', 'es').
  /// [client] Optional custom HTTP client (useful for unit testing).
  ///
  /// Returns a [GeoData] object containing the location details, or `null` if no result found.
  static Future<GeoData?> getDataFromCoordinates({
    required double latitude,
    required double longitude,
    required String googleMapApiKey,
    String? language,
    http.Client? client,
  }) async {
    final geocoder = GoogleGeocoder(apiKey: googleMapApiKey, client: client);
    return geocoder.getDataFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      language: language,
    );
  }

  /// Retrieves location data from a physical address using Google Maps API.
  ///
  /// [address] The physical address to geocode (e.g., "277 Bedford Ave, Brooklyn, NY 11211, USA").
  /// [googleMapApiKey] Your Google Maps API key.
  /// [language] Optional language code for the results (e.g., 'en', 'es').
  /// [client] Optional custom HTTP client (useful for unit testing).
  ///
  /// Returns a [GeoData] object containing the location details, or `null` if no result found.
  static Future<GeoData?> getDataFromAddress({
    required String address,
    required String googleMapApiKey,
    String? language,
    http.Client? client,
  }) async {
    final geocoder = GoogleGeocoder(apiKey: googleMapApiKey, client: client);
    return geocoder.getDataFromAddress(address, language: language);
  }

  /// Retrieves a list of matching locations from coordinates using Google Maps API.
  static Future<List<GeoData>> getAddressesFromCoordinates({
    required double latitude,
    required double longitude,
    required String googleMapApiKey,
    String? language,
    http.Client? client,
  }) async {
    final geocoder = GoogleGeocoder(apiKey: googleMapApiKey, client: client);
    return geocoder.getAddressesFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      language: language,
    );
  }

  /// Retrieves a list of matching locations from an address query using Google Maps API.
  static Future<List<GeoData>> getAddressesFromAddress({
    required String address,
    required String googleMapApiKey,
    String? language,
    http.Client? client,
  }) async {
    final geocoder = GoogleGeocoder(apiKey: googleMapApiKey, client: client);
    return geocoder.getAddressesFromAddress(address, language: language);
  }

  /// Flexible forward geocoding that automatically selects the provider.
  ///
  /// If [provider] is given, it is used.
  /// Else if [googleMapApiKey] is provided, [GoogleGeocoder] is used.
  /// Otherwise, free [NominatimGeocoder] (OpenStreetMap) is used.
  static Future<GeoData?> fromAddress(
    String address, {
    String? googleMapApiKey,
    String? language,
    BaseGeocoder? provider,
    http.Client? client,
  }) async {
    final BaseGeocoder activeProvider =
        provider ??
        (googleMapApiKey != null && googleMapApiKey.isNotEmpty
            ? GoogleGeocoder(apiKey: googleMapApiKey, client: client)
            : NominatimGeocoder(client: client));
    return activeProvider.getDataFromAddress(address, language: language);
  }

  /// Flexible reverse geocoding that automatically selects the provider.
  ///
  /// If [provider] is given, it is used.
  /// Else if [googleMapApiKey] is provided, [GoogleGeocoder] is used.
  /// Otherwise, free [NominatimGeocoder] (OpenStreetMap) is used.
  static Future<GeoData?> fromCoordinates({
    required double latitude,
    required double longitude,
    String? googleMapApiKey,
    String? language,
    BaseGeocoder? provider,
    http.Client? client,
  }) async {
    final BaseGeocoder activeProvider =
        provider ??
        (googleMapApiKey != null && googleMapApiKey.isNotEmpty
            ? GoogleGeocoder(apiKey: googleMapApiKey, client: client)
            : NominatimGeocoder(client: client));
    return activeProvider.getDataFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      language: language,
    );
  }

  // ---------------------------------------------------------------------------
  // Spatial & Geolocation Utilities
  // ---------------------------------------------------------------------------

  /// Calculates the Great-Circle distance in meters between two coordinates.
  static double distanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) => GeoUtils.distanceBetween(startLat, startLon, endLat, endLon);

  /// Calculates the initial compass bearing in degrees (0° - 360°).
  static double bearingBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) => GeoUtils.bearingBetween(startLat, startLon, endLat, endLon);

  /// Checks if [targetLat], [targetLon] is within [radiusInMeters] of [centerLat], [centerLon].
  static bool isWithinRadius({
    required double centerLat,
    required double centerLon,
    required double targetLat,
    required double targetLon,
    required double radiusInMeters,
  }) => GeoUtils.isWithinRadius(
    centerLatitude: centerLat,
    centerLongitude: centerLon,
    targetLatitude: targetLat,
    targetLongitude: targetLon,
    radiusInMeters: radiusInMeters,
  );
}
