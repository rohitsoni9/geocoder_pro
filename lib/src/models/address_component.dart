import 'dart:convert';

/// Represents a single address component returned from a geocoding service.
class GeoAddressComponent {
  /// Creates a [GeoAddressComponent] instance.
  const GeoAddressComponent({
    required this.longName,
    required this.shortName,
    this.types = const [],
  });

  /// Creates a [GeoAddressComponent] from a JSON map.
  factory GeoAddressComponent.fromJson(Map<String, dynamic> json) {
    return GeoAddressComponent(
      longName:
          (json['long_name'] as String?) ?? (json['longName'] as String?) ?? '',
      shortName:
          (json['short_name'] as String?) ??
          (json['shortName'] as String?) ??
          '',
      types:
          (json['types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// Creates a [GeoAddressComponent] from a JSON string.
  factory GeoAddressComponent.fromJsonString(String source) =>
      GeoAddressComponent.fromJson(json.decode(source) as Map<String, dynamic>);

  /// The full name of the address component.
  final String longName;

  /// The abbreviated or short name of the address component.
  final String shortName;

  /// The types associated with this address component.
  final List<String> types;

  /// Checks if this component contains the specified [type].
  bool hasType(String type) => types.contains(type);

  /// Creates a copy with optional updated fields.
  GeoAddressComponent copyWith({
    String? longName,
    String? shortName,
    List<String>? types,
  }) {
    return GeoAddressComponent(
      longName: longName ?? this.longName,
      shortName: shortName ?? this.shortName,
      types: types ?? this.types,
    );
  }

  /// Converts this instance to a map.
  Map<String, dynamic> toMap() {
    return {'long_name': longName, 'short_name': shortName, 'types': types};
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
    if (other is! GeoAddressComponent) {
      return false;
    }
    if (other.longName != longName || other.shortName != shortName) {
      return false;
    }
    if (other.types.length != types.length) {
      return false;
    }
    for (int i = 0; i < types.length; i++) {
      if (other.types[i] != types[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(longName, shortName, Object.hashAll(types));

  @override
  String toString() =>
      'GeoAddressComponent(longName: $longName, shortName: $shortName, types: $types)';
}
