import 'dart:async';
import 'dart:convert';
import 'package:geocoder_pro/src/exceptions/geocoder_exception.dart';
import 'package:geocoder_pro/src/models/address_component.dart';
import 'package:geocoder_pro/src/models/geo_bounds.dart';
import 'package:geocoder_pro/src/models/geo_coordinates.dart';
import 'package:geocoder_pro/src/models/geo_data.dart';
import 'package:geocoder_pro/src/providers/base_geocoder.dart';
import 'package:http/http.dart' as http;

/// Geocoding provider using the free OpenStreetMap Nominatim API (no API key required).
class NominatimGeocoder implements BaseGeocoder {
  /// Creates a [NominatimGeocoder] instance.
  ///
  /// [userAgent] An application identifier required by Nominatim usage policy (e.g. "MyApp/1.0 (contact@example.com)").
  /// [client] An optional custom [http.Client] (useful for testing or custom proxy configuration).
  /// [headers] Optional extra HTTP headers.
  /// [timeout] Optional request timeout (defaults to 15 seconds).
  NominatimGeocoder({
    this.userAgent =
        'GeocoderPro-Flutter/1.1.0 (https://github.com/rohitsoni9/geocoder_pro)',
    http.Client? client,
    this.headers,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  /// User-Agent header for Nominatim policy compliance.
  final String userAgent;

  /// Custom HTTP client instance.
  final http.Client _client;

  /// Extra HTTP headers.
  final Map<String, String>? headers;

  /// Network request timeout.
  final Duration timeout;

  static const String _searchUrl = 'https://nominatim.openstreetmap.org/search';
  static const String _reverseUrl =
      'https://nominatim.openstreetmap.org/reverse';

  Map<String, String> get _defaultHeaders => {
    'User-Agent': userAgent,
    'Accept': 'application/json',
    ...?headers,
  };

  @override
  Future<GeoData?> getDataFromAddress(
    String address, {
    String? language,
    String? countryCodes,
  }) async {
    final results = await getAddressesFromAddress(
      address,
      language: language,
      countryCodes: countryCodes,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<GeoData>> getAddressesFromAddress(
    String address, {
    String? language,
    String? countryCodes,
    int limit = 10,
  }) async {
    if (address.trim().isEmpty) {
      return [];
    }

    final queryParameters = <String, String>{
      'q': address,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': limit.toString(),
    };

    if (language != null && language.isNotEmpty) {
      queryParameters['accept-language'] = language;
    }
    if (countryCodes != null && countryCodes.isNotEmpty) {
      queryParameters['countrycodes'] = countryCodes;
    }

    final uri = Uri.parse(_searchUrl).replace(queryParameters: queryParameters);
    return _sendRequest(uri, isList: true);
  }

  @override
  Future<GeoData?> getDataFromCoordinates({
    required double latitude,
    required double longitude,
    String? language,
    int zoom = 18,
  }) async {
    final results = await getAddressesFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      language: language,
      zoom: zoom,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<GeoData>> getAddressesFromCoordinates({
    required double latitude,
    required double longitude,
    String? language,
    int zoom = 18,
  }) async {
    final queryParameters = <String, String>{
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'format': 'jsonv2',
      'addressdetails': '1',
      'zoom': zoom.toString(),
    };

    if (language != null && language.isNotEmpty) {
      queryParameters['accept-language'] = language;
    }

    final uri = Uri.parse(
      _reverseUrl,
    ).replace(queryParameters: queryParameters);
    return _sendRequest(uri, isList: false);
  }

  Future<List<GeoData>> _sendRequest(Uri uri, {required bool isList}) async {
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: _defaultHeaders)
          .timeout(timeout);
    } on TimeoutException {
      throw const NetworkException('Nominatim OpenStreetMap request timed out');
    } catch (e) {
      throw NetworkException(
        'Failed to connect to Nominatim OpenStreetMap: $e',
        details: e,
      );
    }

    if (response.statusCode == 429) {
      throw const QuotaExceededException(
        'Nominatim rate limit exceeded (HTTP 429). Please throttle your requests.',
      );
    }

    if (response.statusCode != 200) {
      throw NetworkException(
        'Nominatim API returned HTTP ${response.statusCode}',
        statusCode: response.statusCode,
        details: response.body,
      );
    }

    final dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (e) {
      throw GeocoderException(
        'Invalid JSON response from Nominatim API',
        details: response.body,
      );
    }

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_parseNominatimResult)
          .toList();
    } else if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('error')) {
        final error = decoded['error'].toString();
        if (error.toLowerCase().contains('unable to geocode') ||
            error.toLowerCase().contains('not found')) {
          return [];
        }
        throw GeocoderException(error, details: decoded);
      }
      return [_parseNominatimResult(decoded)];
    }

    return [];
  }

  static GeoData _parseNominatimResult(Map<String, dynamic> item) {
    final addressMap = (item['address'] as Map<String, dynamic>?) ?? {};

    final String city =
        (addressMap['city'] as String?) ??
        (addressMap['town'] as String?) ??
        (addressMap['village'] as String?) ??
        (addressMap['municipality'] as String?) ??
        (addressMap['hamlet'] as String?) ??
        '';

    final String state =
        (addressMap['state'] as String?) ??
        (addressMap['province'] as String?) ??
        (addressMap['region'] as String?) ??
        '';

    final String country = (addressMap['country'] as String?) ?? '';
    final String countryCode =
        ((addressMap['country_code'] as String?) ?? '').toUpperCase();

    final String postalCode = (addressMap['postcode'] as String?) ?? '';
    final String streetNumber = (addressMap['house_number'] as String?) ?? '';
    final String street =
        (addressMap['road'] as String?) ??
        (addressMap['pedestrian'] as String?) ??
        (addressMap['street'] as String?) ??
        '';

    final String subLocality =
        (addressMap['suburb'] as String?) ??
        (addressMap['neighbourhood'] as String?) ??
        (addressMap['quarter'] as String?) ??
        '';

    final String subAdminArea =
        (addressMap['county'] as String?) ??
        (addressMap['state_district'] as String?) ??
        '';

    final double lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
    final double lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;

    final String displayName = (item['display_name'] as String?) ?? '';
    final String placeId = (item['place_id']?.toString()) ?? '';
    final String locationType =
        (item['type'] as String?) ?? (item['category'] as String?) ?? '';

    GeoBounds? bounds;
    final bbox = item['boundingbox'] as List<dynamic>?;
    if (bbox != null && bbox.length == 4) {
      final minLat = double.tryParse(bbox[0].toString()) ?? 0.0;
      final maxLat = double.tryParse(bbox[1].toString()) ?? 0.0;
      final minLon = double.tryParse(bbox[2].toString()) ?? 0.0;
      final maxLon = double.tryParse(bbox[3].toString()) ?? 0.0;

      bounds = GeoBounds(
        northeast: GeoCoordinates(latitude: maxLat, longitude: maxLon),
        southwest: GeoCoordinates(latitude: minLat, longitude: minLon),
      );
    }

    final components =
        addressMap.entries.map((entry) {
          return GeoAddressComponent(
            longName: entry.value.toString(),
            shortName: entry.value.toString(),
            types: [entry.key],
          );
        }).toList();

    return GeoData(
      address: displayName,
      formattedAddress: displayName,
      city: city,
      country: country,
      countryCode: countryCode,
      latitude: lat,
      longitude: lon,
      postalCode: postalCode,
      state: state,
      streetNumber: streetNumber,
      street: street,
      subLocality: subLocality,
      subAdminArea: subAdminArea,
      placeId: placeId,
      locationType: locationType,
      bounds: bounds,
      addressComponents: components,
      raw: item,
    );
  }
}
