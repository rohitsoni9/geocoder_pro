import 'dart:convert';
import 'package:geocoder_pro/src/models/geo_coordinates.dart';

/// Represents a rectangular geographic bounding box defined by northeast and southwest coordinates.
class GeoBounds {
  /// Creates a [GeoBounds] with northeast and southwest coordinate limits.
  const GeoBounds({required this.northeast, required this.southwest});

  /// Creates a [GeoBounds] from a JSON map.
  factory GeoBounds.fromJson(Map<String, dynamic> json) {
    return GeoBounds(
      northeast: GeoCoordinates.fromJson(
        (json['northeast'] as Map<String, dynamic>?) ?? {},
      ),
      southwest: GeoCoordinates.fromJson(
        (json['southwest'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  /// Creates a [GeoBounds] from a JSON string.
  factory GeoBounds.fromJsonString(String source) =>
      GeoBounds.fromJson(json.decode(source) as Map<String, dynamic>);

  /// The northeast corner of the bounding box.
  final GeoCoordinates northeast;

  /// The southwest corner of the bounding box.
  final GeoCoordinates southwest;

  /// Checks if the given [coordinates] fall inside this bounding box.
  bool contains(GeoCoordinates coordinates) {
    final bool latInRange =
        coordinates.latitude <= northeast.latitude &&
        coordinates.latitude >= southwest.latitude;
    final bool lngInRange =
        coordinates.longitude <= northeast.longitude &&
        coordinates.longitude >= southwest.longitude;
    return latInRange && lngInRange;
  }

  /// Calculates the center coordinates of this bounding box.
  GeoCoordinates get center {
    final double centerLat = (northeast.latitude + southwest.latitude) / 2;
    final double centerLng = (northeast.longitude + southwest.longitude) / 2;
    return GeoCoordinates(latitude: centerLat, longitude: centerLng);
  }

  /// Creates a copy with optional updated fields.
  GeoBounds copyWith({GeoCoordinates? northeast, GeoCoordinates? southwest}) {
    return GeoBounds(
      northeast: northeast ?? this.northeast,
      southwest: southwest ?? this.southwest,
    );
  }

  /// Converts this instance to a map.
  Map<String, dynamic> toMap() {
    return {'northeast': northeast.toMap(), 'southwest': southwest.toMap()};
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
    return other is GeoBounds &&
        other.northeast == northeast &&
        other.southwest == southwest;
  }

  @override
  int get hashCode => Object.hash(northeast, southwest);

  @override
  String toString() => 'GeoBounds(ne: $northeast, sw: $southwest)';
}
