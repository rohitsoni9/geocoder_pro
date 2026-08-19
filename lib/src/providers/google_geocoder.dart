import 'dart:async';
import 'dart:convert';
import 'package:geocoder_pro/src/exceptions/geocoder_exception.dart';
import 'package:geocoder_pro/src/models/address_component.dart';
import 'package:geocoder_pro/src/models/geo_bounds.dart';
import 'package:geocoder_pro/src/models/geo_data.dart';
import 'package:geocoder_pro/src/providers/base_geocoder.dart';
import 'package:http/http.dart' as http;

/// Geocoding provider using the official Google Maps Geocoding API.
class GoogleGeocoder implements BaseGeocoder {
  /// Creates a [GoogleGeocoder] instance.
  ///
  /// [apiKey] The Google Maps API key with Geocoding API enabled.
  /// [client] An optional custom [http.Client] (useful for testing or custom configuration).
  /// [headers] Optional default headers sent with each request.
  /// [timeout] Optional request timeout (defaults to 15 seconds).
  GoogleGeocoder({
    required this.apiKey,
    http.Client? client,
    this.headers,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  /// Google Maps Geocoding API Key.
  final String apiKey;

  /// Custom HTTP client instance.
  final http.Client _client;

  /// Default HTTP headers.
  final Map<String, String>? headers;

  /// Network request timeout.
  final Duration timeout;

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  @override
  Future<GeoData?> getDataFromAddress(
    String address, {
    String? language,
    String? region,
    String? bounds,
    String? components,
  }) async {
    final results = await getAddressesFromAddress(
      address,
      language: language,
      region: region,
      bounds: bounds,
      components: components,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<GeoData>> getAddressesFromAddress(
    String address, {
    String? language,
    String? region,
    String? bounds,
    String? components,
  }) async {
    if (address.trim().isEmpty) {
      return [];
    }

    final queryParameters = <String, String>{'address': address, 'key': apiKey};

    if (language != null && language.isNotEmpty) {
      queryParameters['language'] = language;
    }
    if (region != null && region.isNotEmpty) {
      queryParameters['region'] = region;
    }
    if (bounds != null && bounds.isNotEmpty) {
      queryParameters['bounds'] = bounds;
    }
    if (components != null && components.isNotEmpty) {
      queryParameters['components'] = components;
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    return _sendRequest(uri);
  }

  @override
  Future<GeoData?> getDataFromCoordinates({
    required double latitude,
    required double longitude,
    String? language,
    String? resultType,
    String? locationType,
  }) async {
    final results = await getAddressesFromCoordinates(
      latitude: latitude,
      longitude: longitude,
      language: language,
      resultType: resultType,
      locationType: locationType,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<GeoData>> getAddressesFromCoordinates({
    required double latitude,
    required double longitude,
    String? language,
    String? resultType,
    String? locationType,
  }) async {
    final queryParameters = <String, String>{
      'latlng': '$latitude,$longitude',
      'key': apiKey,
    };

    if (language != null && language.isNotEmpty) {
      queryParameters['language'] = language;
    }
    if (resultType != null && resultType.isNotEmpty) {
      queryParameters['result_type'] = resultType;
    }
    if (locationType != null && locationType.isNotEmpty) {
      queryParameters['location_type'] = locationType;
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    return _sendRequest(uri);
  }

  Future<List<GeoData>> _sendRequest(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri, headers: headers).timeout(timeout);
    } on TimeoutException {
      throw const NetworkException('Google Maps API request timed out');
    } catch (e) {
      throw NetworkException(
        'Failed to connect to Google Maps API: $e',
        details: e,
      );
    }

    if (response.statusCode != 200) {
      throw NetworkException(
        'Google Maps API returned HTTP ${response.statusCode}',
        statusCode: response.statusCode,
        details: response.body,
      );
    }

    final dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (e) {
      throw GeocoderException(
        'Invalid JSON response from Google Maps API',
        details: response.body,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const GeocoderException(
        'Unexpected response format from Google Maps API',
      );
    }

    final String status = (decoded['status'] as String?) ?? 'UNKNOWN';
    final String? errorMessage = decoded['error_message'] as String?;

    switch (status) {
      case 'OK':
        final results = decoded['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .whereType<Map<String, dynamic>>()
            .map(_parseGoogleResult)
            .toList();

      case 'ZERO_RESULTS':
        return [];

      case 'REQUEST_DENIED':
        throw ApiKeyException(
          errorMessage ??
              'Google Maps API request denied. Please check your API key and billing/quotas.',
          details: decoded,
        );

      case 'OVER_QUERY_LIMIT':
        throw QuotaExceededException(
          errorMessage ?? 'Google Maps API query quota exceeded.',
          details: decoded,
        );

      case 'INVALID_REQUEST':
        throw InvalidRequestException(
          errorMessage ?? 'Google Maps API invalid request parameters.',
          details: decoded,
        );

      default:
        throw GeocoderException(
          errorMessage ?? 'Google Maps API returned status: $status',
          statusCode: status,
          details: decoded,
        );
    }
  }

  static GeoData _parseGoogleResult(Map<String, dynamic> result) {
    final addressComponentsRaw =
        (result['address_components'] as List<dynamic>?) ?? [];

    final components =
        addressComponentsRaw
            .whereType<Map<String, dynamic>>()
            .map(GeoAddressComponent.fromJson)
            .toList();

    GeoAddressComponent? localityComp;
    GeoAddressComponent? subLocalityLevel1Comp;
    GeoAddressComponent? subLocalityComp;
    GeoAddressComponent? neighborhoodComp;
    GeoAddressComponent? postalTownComp;
    GeoAddressComponent? adminArea1Comp;
    GeoAddressComponent? adminArea2Comp;
    GeoAddressComponent? countryComp;
    GeoAddressComponent? postalCodeComp;
    GeoAddressComponent? streetNumberComp;
    GeoAddressComponent? routeComp;

    for (final comp in components) {
      if (comp.hasType('locality')) {
        localityComp = comp;
      }
      if (comp.hasType('sublocality_level_1')) {
        subLocalityLevel1Comp = comp;
      }
      if (comp.hasType('sublocality')) {
        subLocalityComp = comp;
      }
      if (comp.hasType('neighborhood')) {
        neighborhoodComp = comp;
      }
      if (comp.hasType('postal_town')) {
        postalTownComp = comp;
      }
      if (comp.hasType('administrative_area_level_1')) {
        adminArea1Comp = comp;
      }
      if (comp.hasType('administrative_area_level_2')) {
        adminArea2Comp = comp;
      }
      if (comp.hasType('country')) {
        countryComp = comp;
      }
      if (comp.hasType('postal_code')) {
        postalCodeComp = comp;
      }
      if (comp.hasType('street_number')) {
        streetNumberComp = comp;
      }
      if (comp.hasType('route')) {
        routeComp = comp;
      }
    }

    final String city =
        localityComp?.longName ??
        subLocalityLevel1Comp?.longName ??
        postalTownComp?.longName ??
        subLocalityComp?.longName ??
        adminArea2Comp?.longName ??
        '';

    final String subLocality =
        neighborhoodComp?.longName ??
        (subLocalityLevel1Comp != null && city != subLocalityLevel1Comp.longName
            ? subLocalityLevel1Comp.longName
            : subLocalityComp?.longName ?? '');

    final String state = adminArea1Comp?.longName ?? '';
    final String country = countryComp?.longName ?? '';
    final String countryCode = countryComp?.shortName ?? '';
    final String postalCode = postalCodeComp?.longName ?? '';
    final String streetNumber = streetNumberComp?.longName ?? '';
    final String street = routeComp?.longName ?? '';
    final String subAdminArea = adminArea2Comp?.longName ?? '';

    final geometry = (result['geometry'] as Map<String, dynamic>?) ?? {};
    final location = (geometry['location'] as Map<String, dynamic>?) ?? {};
    final double lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
    final double lng = (location['lng'] as num?)?.toDouble() ?? 0.0;
    final String locationType = (geometry['location_type'] as String?) ?? '';

    GeoBounds? bounds;
    final boundsJson =
        (geometry['bounds'] as Map<String, dynamic>?) ??
        (geometry['viewport'] as Map<String, dynamic>?);
    if (boundsJson != null) {
      bounds = GeoBounds.fromJson(boundsJson);
    }

    final plusCodeObj = (result['plus_code'] as Map<String, dynamic>?);
    final String plusCode = (plusCodeObj?['global_code'] as String?) ?? '';
    final String formattedAddress =
        (result['formatted_address'] as String?) ?? '';
    final String placeId = (result['place_id'] as String?) ?? '';

    return GeoData(
      address: formattedAddress,
      formattedAddress: formattedAddress,
      city: city,
      country: country,
      countryCode: countryCode,
      latitude: lat,
      longitude: lng,
      postalCode: postalCode,
      state: state,
      streetNumber: streetNumber,
      street: street,
      subLocality: subLocality,
      subAdminArea: subAdminArea,
      placeId: placeId,
      locationType: locationType,
      plusCode: plusCode,
      bounds: bounds,
      addressComponents: components,
      raw: result,
    );
  }
}
