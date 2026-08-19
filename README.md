# Geocoder Pro

[![pub package](https://img.shields.io/pub/v/geocoder_pro.svg)](https://pub.dev/packages/geocoder_pro)
[![likes](https://img.shields.io/pub/likes/geocoder_pro)](https://pub.dev/packages/geocoder_pro)
[![popularity](https://img.shields.io/pub/popularity/geocoder_pro)](https://pub.dev/packages/geocoder_pro)
[![points](https://img.shields.io/pub/points/geocoder_pro)](https://pub.dev/packages/geocoder_pro)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful, developer-friendly Flutter and Dart package for forward and reverse geocoding. Supports both **Google Maps Geocoding API** and **free OpenStreetMap (Nominatim)**, spatial distance calculations, compass bearings, geofencing, and typed error handling.

---

## 🌟 Highlights & Features

- 🆓 **Free OpenStreetMap (Nominatim) Support** — Geocode without needing an API key or credit card.
- 🌐 **Google Maps Geocoding API** — Full enterprise Google Maps support with component filtering, bounding boxes, and region biasing.
- 🔄 **Forward & Reverse Geocoding** — Convert addresses to geographic coordinates and coordinates back to human-readable addresses.
- 📑 **Multiple Results Support** — Fetch lists of matching locations, not just the single top result.
- 📐 **Spatial & Geolocation Utilities (`GeoUtils`)** — Calculate Haversine distances (meters, km, miles), compass bearings, radius geofencing, and DMS coordinate conversions.
- 🛡️ **Typed Exceptions** — Clean, predictable error handling (`ApiKeyException`, `QuotaExceededException`, `NetworkException`, `NotFoundException`).
- 💎 **Modern & Immutable Models** — Fully immutable `GeoData`, `GeoCoordinates`, and `GeoBounds` with `copyWith`, JSON serialization, equality, and hash codes.
- 🧪 **Test-Ready Architecture** — Inject custom `http.Client` instances to easily mock and test geocoding in your apps.
- 💯 **100% Backward Compatible** — Existing code using `GeocoderPro.getDataFromCoordinates` or `GeocoderPro.getDataFromAddress` continues to work seamlessly.

---

## 📊 Providers Overview

| Feature | OpenStreetMap (Nominatim) | Google Maps API |
| :--- | :---: | :---: |
| **API Key Required** | ❌ No (100% Free) | ✅ Yes |
| **Forward Geocoding** | ✅ Yes | ✅ Yes |
| **Reverse Geocoding** | ✅ Yes | ✅ Yes |
| **Multiple Results** | ✅ Yes | ✅ Yes |
| **Language Support** | ✅ Yes | ✅ Yes |
| **Component Filtering** | ✅ Country codes | ✅ Countries, postal codes, admin areas |
| **Bounding Box Bias** | ✅ Yes | ✅ Viewport & Bounds |

---

## 📦 Installation

Add `geocoder_pro` to your `pubspec.yaml`:

```yaml
dependencies:
  geocoder_pro: ^1.1.0
```

Then import the library:

```dart
import 'package:geocoder_pro/geocoder_pro.dart';
```

---

## 🚀 Quick Start

### 1. Free OpenStreetMap Geocoding (No API Key Required)

```dart
// Forward Geocoding (Address -> Coordinates)
final geoData = await GeocoderPro.nominatim().getDataFromAddress('Eiffel Tower, Paris');

if (geoData != null) {
  print('Address: ${geoData.formattedAddress}');
  print('Latitude: ${geoData.latitude}, Longitude: ${geoData.longitude}');
  print('City: ${geoData.city}, Country: ${geoData.country}');
}

// Reverse Geocoding (Coordinates -> Address)
final reverseData = await GeocoderPro.nominatim().getDataFromCoordinates(
  latitude: 48.8584,
  longitude: 2.2945,
);

print('Resolved Address: ${reverseData?.formattedAddress}');
```

---

### 2. Google Maps Geocoding

```dart
// Initialize Google Geocoder
final googleGeocoder = GeocoderPro.google(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');

// Forward Geocoding
final data = await googleGeocoder.getDataFromAddress(
  '1600 Amphitheatre Pkwy, Mountain View, CA',
  language: 'en',
);

print('Coordinates: ${data?.latitude}, ${data?.longitude}');
print('State: ${data?.state}, Postal Code: ${data?.postalCode}');

// Reverse Geocoding
final loc = await googleGeocoder.getDataFromCoordinates(
  latitude: 37.4220,
  longitude: -122.0841,
);

print('Formatted Address: ${loc?.formattedAddress}');
```

---

### 3. Static Helper Methods (Backward Compatible)

Existing static methods remain fully supported:

```dart
// Google Maps Reverse Geocoding
GeoData? data = await GeocoderPro.getDataFromCoordinates(
  latitude: 40.714224,
  longitude: -73.961452,
  googleMapApiKey: 'YOUR_API_KEY',
  language: 'en',
);

// Google Maps Forward Geocoding
GeoData? place = await GeocoderPro.getDataFromAddress(
  address: '277 Bedford Ave, Brooklyn, NY 11211, USA',
  googleMapApiKey: 'YOUR_API_KEY',
);
```

You can also use the provider-agnostic `fromAddress` and `fromCoordinates` methods which automatically default to OpenStreetMap if no API key is specified:

```dart
// Automatically uses OpenStreetMap when apiKey is omitted
final data = await GeocoderPro.fromAddress('Colosseum, Rome');
```

---

### 4. Fetching Multiple Matching Locations

```dart
final List<GeoData> results = await GeocoderPro.nominatim()
    .getAddressesFromAddress('Springfield', limit: 5);

for (final item in results) {
  print('${item.formattedAddress} -> (${item.latitude}, ${item.longitude})');
}
```

---

## 📐 Spatial Utilities & Distance Calculations

`GeocoderPro` includes spatial tools powered by the Haversine formula:

```dart
const nyLat = 40.7128, nyLon = -74.0060;
const lonLat = 51.5074, lonLon = -0.1278;

// 1. Great-Circle Distance
final double distanceKm = GeoUtils.distanceBetweenKm(nyLat, nyLon, lonLat, lonLon);
final double distanceMiles = GeoUtils.distanceBetweenMiles(nyLat, nyLon, lonLat, lonLon);
print('Distance: $distanceKm km ($distanceMiles miles)'); // ~5570 km

// 2. Initial Compass Bearing
final double bearing = GeoUtils.bearingBetween(nyLat, nyLon, lonLat, lonLon);
print('Bearing: $bearing°'); // e.g. 51.2° (NE)

// 3. Geofencing Check
final bool isNearby = GeoUtils.isWithinRadius(
  centerLatitude: nyLat,
  centerLongitude: nyLon,
  targetLatitude: 40.7306,
  targetLongitude: -73.9352,
  radiusInMeters: 10000, // 10 km radius
);

// 4. Coordinates DMS Formatting
final String dms = GeoUtils.formatCoordinates(40.7128, -74.0060, dms: true);
print(dms); // 40° 42' 46.1" N, 74° 0' 21.6" W

// 5. Human-Readable Distance Formatter
print(GeoUtils.formatDistance(350));    // "350 m"
print(GeoUtils.formatDistance(2500));   // "2.5 km"
print(GeoUtils.formatDistance(5000, imperial: true)); // "3.11 mi"
```

---

## 🛡️ Robust Error Handling

`geocoder_pro` provides structured, typed exceptions so your app can handle API and network issues gracefully:

```dart
try {
  final result = await GeocoderPro.google(apiKey: 'INVALID_KEY')
      .getDataFromAddress('Paris, France');
} on ApiKeyException catch (e) {
  print('API Key Issue: ${e.message}');
} on QuotaExceededException catch (e) {
  print('Rate limit or billing quota exceeded: ${e.message}');
} on NetworkException catch (e) {
  print('Network/Connection error: ${e.message}');
} on GeocoderException catch (e) {
  print('General Geocoding error: ${e.message}');
}
```

---

## 🧪 Unit Testing with Custom HTTP Clients

All providers support injecting a custom `http.Client`:

```dart
import 'package:http/testing.dart';

final mockClient = MockClient((request) async {
  return http.Response(myMockJsonResponse, 200);
});

final geocoder = GeocoderPro.google(
  apiKey: 'TEST_KEY',
  client: mockClient,
);

final result = await geocoder.getDataFromAddress('Test Address');
```

---

## 📱 Interactive Example App

Check out the [`example/`](file:///Users/rohit/projects/Package/geocoder_pro/example) folder for a complete Material 3 Flutter application featuring:
- Live Forward Geocoding with quick presets
- Live Reverse Geocoding with coordinate inputs
- Distance, Bearing & Geofence Calculator
- Interactive Provider Switch (Free OpenStreetMap & Google Maps)
- Raw JSON Inspector modal

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/rohitsoni9/geocoder_pro/issues).