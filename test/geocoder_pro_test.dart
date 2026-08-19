import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoder_pro/geocoder_pro.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends http.BaseClient {
  MockHttpClient(this.handler);

  final Future<http.Response> Function(http.Request request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) {
      final response = await handler(request);
      return http.StreamedResponse(
        Stream.value(utf8.encode(response.body)),
        response.statusCode,
        headers: response.headers,
        reasonPhrase: response.reasonPhrase,
      );
    }
    throw UnimplementedError();
  }
}

const sampleGoogleResponse = '''
{
  "results": [
    {
      "address_components": [
        {
          "long_name": "277",
          "short_name": "277",
          "types": ["street_number"]
        },
        {
          "long_name": "Bedford Avenue",
          "short_name": "Bedford Ave",
          "types": ["route"]
        },
        {
          "long_name": "Williamsburg",
          "short_name": "Williamsburg",
          "types": ["neighborhood", "political"]
        },
        {
          "long_name": "Brooklyn",
          "short_name": "Brooklyn",
          "types": ["sublocality_level_1", "sublocality", "political"]
        },
        {
          "long_name": "Kings County",
          "short_name": "Kings County",
          "types": ["administrative_area_level_2", "political"]
        },
        {
          "long_name": "New York",
          "short_name": "NY",
          "types": ["administrative_area_level_1", "political"]
        },
        {
          "long_name": "United States",
          "short_name": "US",
          "types": ["country", "political"]
        },
        {
          "long_name": "11211",
          "short_name": "11211",
          "types": ["postal_code"]
        }
      ],
      "formatted_address": "277 Bedford Ave, Brooklyn, NY 11211, USA",
      "geometry": {
        "location": {
          "lat": 40.714224,
          "lng": -73.961452
        },
        "location_type": "ROOFTOP",
        "viewport": {
          "northeast": {
            "lat": 40.7155729802915,
            "lng": -73.9601030197085
          },
          "southwest": {
            "lat": 40.7128750197085,
            "lng": -73.9628009802915
          }
        }
      },
      "place_id": "ChIJd8BlQ2BZwokRAFUEcm_qrcA",
      "plus_code": {
        "global_code": "87G8P27Q+C8"
      },
      "types": ["street_address"]
    }
  ],
  "status": "OK"
}
''';

void main() {
  group('GeocoderPro with GoogleGeocoder (Mocked)', () {
    test(
      'getDataFromCoordinates returns parsed GeoData successfully',
      () async {
        final mockClient = MockHttpClient((request) async {
          expect(request.url.queryParameters['latlng'], '40.714224,-73.961452');
          expect(request.url.queryParameters['key'], 'TEST_KEY');
          return http.Response(sampleGoogleResponse, 200);
        });

        final result = await GeocoderPro.getDataFromCoordinates(
          latitude: 40.714224,
          longitude: -73.961452,
          googleMapApiKey: 'TEST_KEY',
          client: mockClient,
        );

        expect(result, isNotNull);
        expect(result!.address, '277 Bedford Ave, Brooklyn, NY 11211, USA');
        expect(result.city, 'Brooklyn');
        expect(result.state, 'New York');
        expect(result.country, 'United States');
        expect(result.countryCode, 'US');
        expect(result.postalCode, '11211');
        expect(result.streetNumber, '277');
        expect(result.street, 'Bedford Avenue');
        expect(result.subLocality, 'Williamsburg');
        expect(result.subAdminArea, 'Kings County');
        expect(result.placeId, 'ChIJd8BlQ2BZwokRAFUEcm_qrcA');
        expect(result.locationType, 'ROOFTOP');
        expect(result.plusCode, '87G8P27Q+C8');
        expect(result.bounds, isNotNull);
      },
    );

    test('getDataFromAddress returns parsed GeoData successfully', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.queryParameters['address'], '277 Bedford Ave');
        expect(request.url.queryParameters['key'], 'TEST_KEY');
        expect(request.url.queryParameters['language'], 'en');
        return http.Response(sampleGoogleResponse, 200);
      });

      final result = await GeocoderPro.getDataFromAddress(
        address: '277 Bedford Ave',
        googleMapApiKey: 'TEST_KEY',
        language: 'en',
        client: mockClient,
      );

      expect(result, isNotNull);
      expect(result!.latitude, 40.714224);
      expect(result.longitude, -73.961452);
    });

    test('getAddressesFromAddress returns list of results', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response(sampleGoogleResponse, 200);
      });

      final list = await GeocoderPro.getAddressesFromAddress(
        address: 'Bedford Ave',
        googleMapApiKey: 'TEST_KEY',
        client: mockClient,
      );

      expect(list.length, 1);
      expect(list.first.city, 'Brooklyn');
    });

    test('handles ZERO_RESULTS gracefully without throwing', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('{"results": [], "status": "ZERO_RESULTS"}', 200);
      });

      final result = await GeocoderPro.getDataFromAddress(
        address: 'Nonexistent Place XYZ 9999',
        googleMapApiKey: 'TEST_KEY',
        client: mockClient,
      );

      expect(result, isNull);

      final list = await GeocoderPro.getAddressesFromAddress(
        address: 'Nonexistent Place XYZ 9999',
        googleMapApiKey: 'TEST_KEY',
        client: mockClient,
      );
      expect(list, isEmpty);
    });

    test('throws ApiKeyException when status is REQUEST_DENIED', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response(
          '{"error_message": "The provided API key is invalid.", "results": [], "status": "REQUEST_DENIED"}',
          200,
        );
      });

      expect(
        () => GeocoderPro.getDataFromAddress(
          address: 'Paris',
          googleMapApiKey: 'INVALID_KEY',
          client: mockClient,
        ),
        throwsA(isA<ApiKeyException>()),
      );
    });

    test(
      'throws QuotaExceededException when status is OVER_QUERY_LIMIT',
      () async {
        final mockClient = MockHttpClient((request) async {
          return http.Response(
            '{"error_message": "You have exceeded your request quota for this API.", "results": [], "status": "OVER_QUERY_LIMIT"}',
            200,
          );
        });

        expect(
          () => GeocoderPro.getDataFromAddress(
            address: 'London',
            googleMapApiKey: 'TEST_KEY',
            client: mockClient,
          ),
          throwsA(isA<QuotaExceededException>()),
        );
      },
    );

    test('throws NetworkException on HTTP 500', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      expect(
        () => GeocoderPro.getDataFromAddress(
          address: 'Rome',
          googleMapApiKey: 'TEST_KEY',
          client: mockClient,
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('GoogleGeocoder factory builder works properly', () {
      final geocoder = GeocoderPro.google(
        apiKey: 'MY_KEY',
        timeout: const Duration(seconds: 5),
      );
      expect(geocoder.apiKey, 'MY_KEY');
      expect(geocoder.timeout, const Duration(seconds: 5));
    });

    test('spatial helper shortcuts delegate to GeoUtils', () {
      final distance = GeocoderPro.distanceBetween(0, 0, 0, 1);
      expect(distance, greaterThan(111000));

      final bearing = GeocoderPro.bearingBetween(0, 0, 0, 1);
      expect(bearing, closeTo(90, 0.1));

      final within = GeocoderPro.isWithinRadius(
        centerLat: 0,
        centerLon: 0,
        targetLat: 0,
        targetLon: 0.0001,
        radiusInMeters: 50,
      );
      expect(within, isTrue);
    });
  });
}
