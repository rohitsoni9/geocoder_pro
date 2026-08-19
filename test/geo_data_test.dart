import 'package:flutter_test/flutter_test.dart';
import 'package:geocoder_pro/geocoder_pro.dart';

void main() {
  group('GeoCoordinates', () {
    test('instantiates and validates coordinates correctly', () {
      const coords = GeoCoordinates(latitude: 37.7749, longitude: -122.4194);
      expect(coords.latitude, 37.7749);
      expect(coords.longitude, -122.4194);
      expect(coords.isValid, isTrue);

      const invalidCoords = GeoCoordinates(latitude: 95.0, longitude: 200.0);
      expect(invalidCoords.isValid, isFalse);
    });

    test('toDMS formats correctly', () {
      const coords = GeoCoordinates(latitude: 40.7128, longitude: -74.0060);
      final dms = coords.toDMS();
      expect(dms, contains('40°'));
      expect(dms, contains('N'));
      expect(dms, contains('74°'));
      expect(dms, contains('W'));
    });

    test('distanceTo and bearingTo compute properly', () {
      const p1 = GeoCoordinates(latitude: 0, longitude: 0);
      const p2 = GeoCoordinates(latitude: 0, longitude: 1);
      final distance = p1.distanceTo(p2);
      expect(distance, greaterThan(111000));
      expect(distance, lessThan(112000));

      final bearing = p1.bearingTo(p2);
      expect(bearing, closeTo(90.0, 0.1));
    });

    test('serialization to/from map and json works', () {
      const coords = GeoCoordinates(latitude: 51.5074, longitude: -0.1278);
      final map = coords.toMap();
      final fromMap = GeoCoordinates.fromJson(map);
      expect(fromMap, equals(coords));

      final jsonStr = coords.toJsonString();
      final fromJson = GeoCoordinates.fromJsonString(jsonStr);
      expect(fromJson, equals(coords));
    });

    test('copyWith works', () {
      const coords = GeoCoordinates(latitude: 10, longitude: 20);
      final updated = coords.copyWith(latitude: 15);
      expect(updated.latitude, 15);
      expect(updated.longitude, 20);
    });
  });

  group('GeoBounds', () {
    test('contains check works', () {
      const bounds = GeoBounds(
        northeast: GeoCoordinates(latitude: 40.0, longitude: 40.0),
        southwest: GeoCoordinates(latitude: 10.0, longitude: 10.0),
      );

      expect(
        bounds.contains(const GeoCoordinates(latitude: 25.0, longitude: 25.0)),
        isTrue,
      );
      expect(
        bounds.contains(const GeoCoordinates(latitude: 5.0, longitude: 25.0)),
        isFalse,
      );
      expect(
        bounds.contains(const GeoCoordinates(latitude: 25.0, longitude: 45.0)),
        isFalse,
      );
    });

    test('center calculation works', () {
      const bounds = GeoBounds(
        northeast: GeoCoordinates(latitude: 40.0, longitude: 40.0),
        southwest: GeoCoordinates(latitude: 10.0, longitude: 10.0),
      );
      final center = bounds.center;
      expect(center.latitude, 25.0);
      expect(center.longitude, 25.0);
    });

    test('serialization works', () {
      const bounds = GeoBounds(
        northeast: GeoCoordinates(latitude: 40.0, longitude: 40.0),
        southwest: GeoCoordinates(latitude: 10.0, longitude: 10.0),
      );
      final map = bounds.toMap();
      final fromMap = GeoBounds.fromJson(map);
      expect(fromMap, equals(bounds));
    });
  });

  group('GeoAddressComponent', () {
    test('hasType check and serialization works', () {
      const comp = GeoAddressComponent(
        longName: 'California',
        shortName: 'CA',
        types: ['administrative_area_level_1', 'political'],
      );

      expect(comp.hasType('political'), isTrue);
      expect(comp.hasType('country'), isFalse);

      final map = comp.toMap();
      final fromMap = GeoAddressComponent.fromJson(map);
      expect(fromMap, equals(comp));
    });
  });

  group('GeoData', () {
    test('instantiates with all fields and computes distances', () {
      const data1 = GeoData(
        address: '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA',
        city: 'Mountain View',
        country: 'United States',
        countryCode: 'US',
        latitude: 37.4220,
        longitude: -122.0841,
        postalCode: '94043',
        state: 'California',
        streetNumber: '1600',
        street: 'Amphitheatre Pkwy',
      );

      const data2 = GeoData(
        address: '1 Infinite Loop, Cupertino, CA 95014, USA',
        city: 'Cupertino',
        country: 'United States',
        countryCode: 'US',
        latitude: 37.3318,
        longitude: -122.0311,
        postalCode: '95014',
        state: 'California',
        streetNumber: '1',
        street: 'Infinite Loop',
      );

      final distance = data1.distanceTo(data2);
      expect(distance, greaterThan(10000));
      expect(distance, lessThan(15000));

      final coords = data1.coordinates;
      expect(coords.latitude, 37.4220);
      expect(coords.longitude, -122.0841);
    });

    test('serialization to/from map and json works', () {
      const data = GeoData(
        address: '277 Bedford Ave, Brooklyn, NY 11211, USA',
        city: 'Brooklyn',
        country: 'United States',
        countryCode: 'US',
        latitude: 40.714224,
        longitude: -73.961452,
        postalCode: '11211',
        state: 'New York',
        streetNumber: '277',
        street: 'Bedford Ave',
        subLocality: 'Williamsburg',
        subAdminArea: 'Kings County',
        placeId: 'ChIJd8BlQ2BZwokRAFUEcm_qrcA',
      );

      final map = data.toMap();
      final fromMap = GeoData.fromMap(map);
      expect(fromMap.address, data.address);
      expect(fromMap.city, data.city);
      expect(fromMap.country, data.country);
      expect(fromMap.latitude, data.latitude);
      expect(fromMap.longitude, data.longitude);
      expect(fromMap.postalCode, data.postalCode);
      expect(fromMap.state, data.state);
      expect(fromMap.placeId, data.placeId);
      expect(fromMap, equals(data));

      final jsonStr = data.toJsonString();
      final fromJson = GeoData.fromJsonString(jsonStr);
      expect(fromJson, equals(data));
    });

    test('copyWith updates fields correctly', () {
      const data = GeoData(
        address: 'Old Address',
        city: 'Old City',
        country: 'Old Country',
        countryCode: 'OC',
        latitude: 1.0,
        longitude: 2.0,
        postalCode: '00000',
        state: 'Old State',
        streetNumber: '10',
      );

      final updated = data.copyWith(city: 'New City', latitude: 3.0);

      expect(updated.city, 'New City');
      expect(updated.latitude, 3.0);
      expect(updated.address, 'Old Address');
      expect(updated.country, 'Old Country');
    });
  });

  group('GeocodeResponse', () {
    test('convenience getters work properly', () {
      const item = GeoData(
        address: 'Main St',
        city: 'City',
        country: 'Country',
        countryCode: 'CC',
        latitude: 10,
        longitude: 20,
        postalCode: '12345',
        state: 'State',
        streetNumber: '1',
      );

      const response = GeocodeResponse(results: [item], status: 'OK');

      expect(response.isSuccessful, isTrue);
      expect(response.isZeroResults, isFalse);
      expect(response.firstResult, equals(item));

      const emptyResponse = GeocodeResponse(
        results: [],
        status: 'ZERO_RESULTS',
      );
      expect(emptyResponse.isSuccessful, isFalse);
      expect(emptyResponse.isZeroResults, isTrue);
      expect(emptyResponse.firstResult, isNull);
    });
  });
}
