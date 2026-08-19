## 1.1.0

* **OpenStreetMap (Nominatim) Support**: Added 100% free geocoding provider without requiring an API key.
* **Multi-Provider Architecture**: Added `BaseGeocoder`, `GoogleGeocoder`, and `NominatimGeocoder` with flexible provider selection.
* **Multiple Results Support**: Added `getAddressesFromAddress` and `getAddressesFromCoordinates` across all providers.
* **Spatial & Geolocation Utilities**: Added `GeoUtils` with Haversine distance calculations (meters, km, miles), compass bearing calculation, geofencing radius checks, and DMS coordinate conversions.
* **Enhanced & Immutable Models**: Refactored `GeoData`, `GeoCoordinates`, `GeoBounds`, and `GeoAddressComponent` with `const` constructors, `copyWith`, JSON/Map serialization, value equality, and hash code implementations.
* **Typed Exceptions**: Added `GeocoderException`, `ApiKeyException`, `QuotaExceededException`, `NotFoundException`, and `NetworkException` for reliable error handling.
* **Custom HTTP Client Support**: Enabled dependency injection of `http.Client` across providers for streamlined unit and integration testing.
* **Refreshed Material 3 Example App**: Multi-tab interactive showcase with provider switching, live geocoding, preset queries, distance calculator, and raw JSON modal inspector.
* **Full Backward Compatibility**: Preserved all existing static API method signatures and legacy import shims.
* **Quality & Linting**: Elevated package compliance with strict Dart 3 type checking, 100% test pass rate across 33 unit tests, and 0 analyzer warnings.

## 1.0.3

* Added comprehensive documentation for all classes and methods
* Improved error handling in geocoding operations
* Added support for country codes in geocoding results
* Enhanced example application with Material Design 3 UI
* Added loading states and better error feedback in example app

## 1.0.2

* Initial release with basic geocoding functionality
* Support for address validation and standardization
* Basic error handling and response formatting

## 1.0.0

* Adding Location Type
* Read ```README.md```
