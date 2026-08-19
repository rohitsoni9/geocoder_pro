/// Base class for all geocoding-related exceptions.
class GeocoderException implements Exception {
  /// Creates a [GeocoderException] with an error [message] and optional [statusCode].
  const GeocoderException(this.message, {this.statusCode, this.details});

  /// The human-readable error message.
  final String message;

  /// The HTTP or API status code, if available.
  final dynamic statusCode;

  /// Additional diagnostic details or original provider response.
  final dynamic details;

  @override
  String toString() {
    if (statusCode != null) {
      return 'GeocoderException ($statusCode): $message';
    }
    return 'GeocoderException: $message';
  }
}

/// Thrown when an API key is missing, invalid, or unauthorized.
class ApiKeyException extends GeocoderException {
  /// Creates an [ApiKeyException].
  const ApiKeyException(
    super.message, {
    super.statusCode = 'REQUEST_DENIED',
    super.details,
  });
}

/// Thrown when the query limit or API quota has been exceeded.
class QuotaExceededException extends GeocoderException {
  /// Creates a [QuotaExceededException].
  const QuotaExceededException(
    super.message, {
    super.statusCode = 'OVER_QUERY_LIMIT',
    super.details,
  });
}

/// Thrown when no geocoding results were found for the query.
class NotFoundException extends GeocoderException {
  /// Creates a [NotFoundException].
  const NotFoundException(
    super.message, {
    super.statusCode = 'ZERO_RESULTS',
    super.details,
  });
}

/// Thrown when network connectivity fails, request times out, or server returns 5xx.
class NetworkException extends GeocoderException {
  /// Creates a [NetworkException].
  const NetworkException(super.message, {super.statusCode, super.details});
}

/// Thrown when the geocoding request parameters are malformed or invalid.
class InvalidRequestException extends GeocoderException {
  /// Creates an [InvalidRequestException].
  const InvalidRequestException(
    super.message, {
    super.statusCode = 'INVALID_REQUEST',
    super.details,
  });
}
