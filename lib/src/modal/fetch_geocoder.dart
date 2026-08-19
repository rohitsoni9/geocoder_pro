import 'dart:convert';

/// Converts a JSON string into a [FetchGeocoder] object.
FetchGeocoder fetchGeocoderFromJson(String str) =>
    FetchGeocoder.fromJson(json.decode(str) as Map<String, dynamic>);

/// Converts a [FetchGeocoder] object into a JSON string.
String fetchGeocoderToJson(FetchGeocoder data) => json.encode(data.toJson());

/// Backward compatibility alias for the legacy typo in fetchGeocoderToJson.
@Deprecated('Use fetchGeocoderToJson instead')
String tetchGeocoderToJson(FetchGeocoder data) => fetchGeocoderToJson(data);

/// Represents the response from the Google Maps Geocoding API (Legacy wrapper).
class FetchGeocoder {
  /// Creates a new instance of [FetchGeocoder].
  FetchGeocoder({required this.results, required this.status});

  /// The list of geocoding results matching the request.
  List<Result> results;

  /// The status of the geocoding request (e.g., "OK", "ZERO_RESULTS").
  String status;

  /// Creates a [FetchGeocoder] instance from a JSON map.
  factory FetchGeocoder.fromJson(Map<String, dynamic> json) => FetchGeocoder(
    results:
        (json['results'] as List<dynamic>?)
            ?.map((x) => Result.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
    status: (json['status'] as String?) ?? 'UNKNOWN',
  );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'results': results.map((x) => x.toJson()).toList(),
    'status': status,
  };
}

/// Represents a single geocoding result from the Google Maps API.
class Result {
  /// Creates a new instance of [Result].
  Result({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
    required this.types,
  });

  /// The list of address components that make up this location.
  List<AddressComponent> addressComponents;

  /// The complete formatted address of the location.
  String formattedAddress;

  /// The geographical information of the location.
  Geometry geometry;

  /// The unique identifier for this place in the Google Places database.
  String placeId;

  /// The types of location this result represents.
  List<String> types;

  /// Creates a [Result] instance from a JSON map.
  factory Result.fromJson(Map<String, dynamic> json) => Result(
    addressComponents:
        (json['address_components'] as List<dynamic>?)
            ?.map((x) => AddressComponent.fromJson(x as Map<String, dynamic>))
            .toList() ??
        [],
    formattedAddress: (json['formatted_address'] as String?) ?? '',
    geometry:
        json['geometry'] != null
            ? Geometry.fromJson(json['geometry'] as Map<String, dynamic>)
            : Geometry(
              location: Location(lat: 0, lng: 0),
              locationType: LocationType.approximate,
            ),
    placeId: (json['place_id'] as String?) ?? '',
    types:
        (json['types'] as List<dynamic>?)?.map((x) => x.toString()).toList() ??
        [],
  );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'address_components': addressComponents.map((x) => x.toJson()).toList(),
    'formatted_address': formattedAddress,
    'geometry': geometry.toJson(),
    'place_id': placeId,
    'types': types,
  };
}

/// Represents a component of an address.
class AddressComponent {
  /// Creates a new instance of [AddressComponent].
  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  /// The full name of the address component.
  String longName;

  /// The abbreviated name of the address component.
  String shortName;

  /// The types of this address component.
  List<String> types;

  /// Creates an [AddressComponent] instance from a JSON map.
  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      AddressComponent(
        longName: (json['long_name'] as String?) ?? '',
        shortName: (json['short_name'] as String?) ?? '',
        types:
            (json['types'] as List<dynamic>?)
                ?.map((x) => x.toString())
                .toList() ??
            [],
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'long_name': longName,
    'short_name': shortName,
    'types': types,
  };
}

/// Represents the geographical information of a location.
class Geometry {
  /// Creates a new instance of [Geometry].
  Geometry({required this.location, required this.locationType});

  /// The coordinates of the location.
  Location location;

  /// The type of location.
  LocationType locationType;

  /// Creates a [Geometry] instance from a JSON map.
  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    location:
        json['location'] != null
            ? Location.fromJson(json['location'] as Map<String, dynamic>)
            : Location(lat: 0, lng: 0),
    locationType:
        locationTypeValues.map[json['location_type']] ??
        LocationType.approximate,
  );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'location': location.toJson(),
    'location_type': locationTypeValues.reverse[locationType],
  };
}

/// Represents a viewport (bounding box) for a location.
class Viewport {
  /// Creates a new instance of [Viewport].
  Viewport({required this.northeast, required this.southwest});

  /// The northeast corner of the viewport.
  Location northeast;

  /// The southwest corner of the viewport.
  Location southwest;

  /// Creates a [Viewport] instance from a JSON map.
  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
    northeast:
        json['northeast'] != null
            ? Location.fromJson(json['northeast'] as Map<String, dynamic>)
            : Location(lat: 0, lng: 0),
    southwest:
        json['southwest'] != null
            ? Location.fromJson(json['southwest'] as Map<String, dynamic>)
            : Location(lat: 0, lng: 0),
  );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'northeast': northeast.toJson(),
    'southwest': southwest.toJson(),
  };
}

/// Represents a geographical location with latitude and longitude coordinates.
class Location {
  /// Creates a new instance of [Location].
  Location({required this.lat, required this.lng});

  /// The latitude coordinate in decimal degrees.
  double lat;

  /// The longitude coordinate in decimal degrees.
  double lng;

  /// Creates a [Location] instance from a JSON map.
  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
  );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

/// The type of location returned by the Google Maps Geocoding API.
enum LocationType {
  /// The location is a rooftop location.
  roofTop,

  /// The location is a geometric center.
  geometricCenter,

  /// The location is an approximate location.
  approximate,

  /// The location is interpolated from a range.
  rangeInterpolated,
}

/// Maps between [LocationType] enum values and their string representations.
final locationTypeValues = EnumValues({
  'APPROXIMATE': LocationType.approximate,
  'GEOMETRIC_CENTER': LocationType.geometricCenter,
  'ROOFTOP': LocationType.roofTop,
  'RANGE_INTERPOLATED': LocationType.rangeInterpolated,
});

/// A utility class for mapping between enum values and their string representations.
class EnumValues<T> {
  /// Creates a new instance of [EnumValues].
  EnumValues(this.map)
    : reverseMap = {for (var entry in map.entries) entry.value: entry.key};

  /// The map of string values to enum values.
  final Map<String, T> map;

  /// The map of enum values to string values.
  final Map<T, String> reverseMap;

  /// Gets the reverse map of enum values to string values.
  Map<T, String> get reverse => reverseMap;
}
