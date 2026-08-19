import 'dart:convert';
import 'package:geocoder_pro/src/models/address_component.dart';
import 'package:geocoder_pro/src/models/geo_bounds.dart';
import 'package:geocoder_pro/src/models/geo_coordinates.dart';

/// A comprehensive data model class representing geographical location information.
///
/// Contains detailed address breakdown, geographic coordinates, administrative details,
/// and helper methods for distance calculations and formatting.
class GeoData {
  /// Creates a new instance of [GeoData].
  const GeoData({
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.postalCode,
    required this.state,
    required this.countryCode,
    required this.streetNumber,
    this.street = '',
    this.subLocality = '',
    this.subAdminArea = '',
    this.formattedAddress = '',
    this.placeId = '',
    this.locationType = '',
    this.plusCode = '',
    this.bounds,
    this.addressComponents = const [],
    this.raw = const {},
  });

  /// Creates a [GeoData] instance from a Map representation.
  factory GeoData.fromMap(Map<String, dynamic> map) {
    return GeoData(
      address:
          (map['address'] as String?) ??
          (map['formatted_address'] as String?) ??
          '',
      city: (map['city'] as String?) ?? '',
      country: (map['country'] as String?) ?? '',
      latitude:
          (map['latitude'] as num?)?.toDouble() ??
          (map['lat'] as num?)?.toDouble() ??
          0.0,
      longitude:
          (map['longitude'] as num?)?.toDouble() ??
          (map['lng'] as num?)?.toDouble() ??
          (map['lon'] as num?)?.toDouble() ??
          0.0,
      postalCode:
          (map['postalCode'] as String?) ??
          (map['postal_code'] as String?) ??
          (map['postcode'] as String?) ??
          '',
      state: (map['state'] as String?) ?? '',
      countryCode:
          (map['countryCode'] as String?) ??
          (map['country_code'] as String?) ??
          '',
      streetNumber:
          (map['streetNumber'] as String?) ??
          (map['street_number'] as String?) ??
          (map['house_number'] as String?) ??
          '',
      street:
          (map['street'] as String?) ??
          (map['thoroughfare'] as String?) ??
          (map['road'] as String?) ??
          '',
      subLocality:
          (map['subLocality'] as String?) ??
          (map['sub_locality'] as String?) ??
          (map['neighbourhood'] as String?) ??
          (map['suburb'] as String?) ??
          '',
      subAdminArea:
          (map['subAdminArea'] as String?) ??
          (map['sub_admin_area'] as String?) ??
          (map['county'] as String?) ??
          '',
      formattedAddress:
          (map['formattedAddress'] as String?) ??
          (map['formatted_address'] as String?) ??
          (map['display_name'] as String?) ??
          (map['address'] as String?) ??
          '',
      placeId:
          (map['placeId'] as String?) ??
          (map['place_id'] as String?)?.toString() ??
          '',
      locationType:
          (map['locationType'] as String?) ??
          (map['location_type'] as String?) ??
          '',
      plusCode:
          (map['plusCode'] as String?) ?? (map['plus_code'] as String?) ?? '',
      bounds:
          map['bounds'] != null
              ? GeoBounds.fromJson(map['bounds'] as Map<String, dynamic>)
              : null,
      addressComponents:
          (map['addressComponents'] as List<dynamic>?)
              ?.map(
                (e) => GeoAddressComponent.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          (map['address_components'] as List<dynamic>?)
              ?.map(
                (e) => GeoAddressComponent.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      raw: (map['raw'] as Map<String, dynamic>?) ?? map,
    );
  }

  /// Creates a [GeoData] instance from a JSON map.
  factory GeoData.fromJson(Map<String, dynamic> json) => GeoData.fromMap(json);

  /// Creates a [GeoData] instance from a JSON string.
  factory GeoData.fromJsonString(String source) =>
      GeoData.fromJson(json.decode(source) as Map<String, dynamic>);

  /// The complete formatted address of the location.
  final String address;

  /// The city or locality name where the location is situated.
  final String city;

  /// The country name where the location is situated.
  final String country;

  /// The latitude coordinate in decimal degrees.
  final double latitude;

  /// The longitude coordinate in decimal degrees.
  final double longitude;

  /// The postal or ZIP code of the location.
  final String postalCode;

  /// The state, province, or region name.
  final String state;

  /// The two-letter country code (ISO 3166-1 alpha-2) of the location.
  final String countryCode;

  /// The street number / house number of the location.
  final String streetNumber;

  /// The street name or route.
  final String street;

  /// The sub-locality, neighborhood, or district.
  final String subLocality;

  /// The sub-administrative area or county.
  final String subAdminArea;

  /// The formatted display address string.
  final String formattedAddress;

  /// The unique place identifier from the provider (e.g. Google Place ID or OSM ID).
  final String placeId;

  /// The accuracy / geometry location type (e.g., ROOFTOP, APPROXIMATE).
  final String locationType;

  /// The Open Location Code (Plus Code) if available.
  final String plusCode;

  /// The bounding box or viewport limits of the location.
  final GeoBounds? bounds;

  /// The detailed list of individual address components.
  final List<GeoAddressComponent> addressComponents;

  /// The raw payload returned from the geocoding provider.
  final Map<String, dynamic> raw;

  /// Returns coordinates as a [GeoCoordinates] object.
  GeoCoordinates get coordinates =>
      GeoCoordinates(latitude: latitude, longitude: longitude);

  /// Calculates the Great-Circle distance in meters from this location to [other].
  double distanceTo(GeoData other) => coordinates.distanceTo(other.coordinates);

  /// Calculates the Great-Circle distance in meters from this location to [coords].
  double distanceToCoordinates(GeoCoordinates coords) =>
      coordinates.distanceTo(coords);

  /// Calculates the initial compass bearing in degrees (0° - 360°) towards [other].
  double bearingTo(GeoData other) => coordinates.bearingTo(other.coordinates);

  /// Creates a copy of this [GeoData] with given fields replaced by new values.
  GeoData copyWith({
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? postalCode,
    String? state,
    String? countryCode,
    String? streetNumber,
    String? street,
    String? subLocality,
    String? subAdminArea,
    String? formattedAddress,
    String? placeId,
    String? locationType,
    String? plusCode,
    GeoBounds? bounds,
    List<GeoAddressComponent>? addressComponents,
    Map<String, dynamic>? raw,
  }) {
    return GeoData(
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      postalCode: postalCode ?? this.postalCode,
      state: state ?? this.state,
      countryCode: countryCode ?? this.countryCode,
      streetNumber: streetNumber ?? this.streetNumber,
      street: street ?? this.street,
      subLocality: subLocality ?? this.subLocality,
      subAdminArea: subAdminArea ?? this.subAdminArea,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      placeId: placeId ?? this.placeId,
      locationType: locationType ?? this.locationType,
      plusCode: plusCode ?? this.plusCode,
      bounds: bounds ?? this.bounds,
      addressComponents: addressComponents ?? this.addressComponents,
      raw: raw ?? this.raw,
    );
  }

  /// Converts this instance to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'postalCode': postalCode,
      'state': state,
      'countryCode': countryCode,
      'streetNumber': streetNumber,
      'street': street,
      'subLocality': subLocality,
      'subAdminArea': subAdminArea,
      'formattedAddress':
          formattedAddress.isNotEmpty ? formattedAddress : address,
      'placeId': placeId,
      'locationType': locationType,
      'plusCode': plusCode,
      'bounds': bounds?.toMap(),
      'addressComponents': addressComponents.map((e) => e.toMap()).toList(),
    };
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
    return other is GeoData &&
        other.address == address &&
        other.city == city &&
        other.country == country &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.postalCode == postalCode &&
        other.state == state &&
        other.countryCode == countryCode &&
        other.streetNumber == streetNumber &&
        other.street == street &&
        other.subLocality == subLocality &&
        other.subAdminArea == subAdminArea &&
        other.placeId == placeId;
  }

  @override
  int get hashCode => Object.hash(
    address,
    city,
    country,
    latitude,
    longitude,
    postalCode,
    state,
    countryCode,
    streetNumber,
    street,
    placeId,
  );

  @override
  String toString() =>
      'GeoData(address: $address, city: $city, state: $state, country: $country, '
      'coords: ($latitude, $longitude), postalCode: $postalCode)';
}
