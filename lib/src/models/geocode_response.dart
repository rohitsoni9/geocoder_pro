import 'package:geocoder_pro/src/models/geo_data.dart';

/// Represents a standardized geocoding response holding results and metadata.
class GeocodeResponse {
  /// Creates a [GeocodeResponse] instance.
  const GeocodeResponse({
    required this.results,
    required this.status,
    this.errorMessage,
    this.raw = const {},
  });

  /// The list of [GeoData] results matched by the query.
  final List<GeoData> results;

  /// The status string returned from the provider (e.g. "OK", "ZERO_RESULTS").
  final String status;

  /// An optional error message when the request fails.
  final String? errorMessage;

  /// The raw response map from the provider.
  final Map<String, dynamic> raw;

  /// Returns the first [GeoData] in the results, or `null` if empty.
  GeoData? get firstResult => results.isNotEmpty ? results.first : null;

  /// Indicates if the response was successful and contains results.
  bool get isSuccessful => status == 'OK' && results.isNotEmpty;

  /// Indicates if no results were found.
  bool get isZeroResults => status == 'ZERO_RESULTS' || results.isEmpty;

  @override
  String toString() =>
      'GeocodeResponse(status: $status, count: ${results.length}, error: $errorMessage)';
}
