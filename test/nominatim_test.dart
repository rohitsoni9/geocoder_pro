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

const sampleNominatimSearch = '''
[
  {
    "place_id": 298492043,
    "licence": "Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
    "osm_type": "node",
    "osm_id": 268995335,
    "lat": "48.8582602",
    "lon": "2.29449905431968",
    "category": "tourism",
    "type": "attraction",
    "place_rank": 30,
    "importance": 0.8872,
    "addresstype": "tourism",
    "name": "Tour Eiffel",
    "display_name": "Tour Eiffel, 5, Avenue Anatole France, Quartier du Gros-Caillou, Paris 7e Arrondissement, Paris, Île-de-France, France métropolitaine, 75007, France",
    "address": {
      "tourism": "Tour Eiffel",
      "house_number": "5",
      "road": "Avenue Anatole France",
      "neighbourhood": "Quartier du Gros-Caillou",
      "suburb": "Paris 7e Arrondissement",
      "city": "Paris",
      "state": "Île-de-France",
      "postcode": "75007",
      "country": "France",
      "country_code": "fr"
    },
    "boundingbox": [
      "48.8574753",
      "48.8590453",
      "2.2933084",
      "2.2956897"
    ]
  }
]
''';

const sampleNominatimReverse = '''
{
  "place_id": 298492043,
  "lat": "48.8582602",
  "lon": "2.29449905431968",
  "category": "tourism",
  "type": "attraction",
  "display_name": "Tour Eiffel, Paris, France",
  "address": {
    "tourism": "Tour Eiffel",
    "house_number": "5",
    "road": "Avenue Anatole France",
    "city": "Paris",
    "state": "Île-de-France",
    "postcode": "75007",
    "country": "France",
    "country_code": "fr"
  },
  "boundingbox": [
    "48.8574753",
    "48.8590453",
    "2.2933084",
    "2.2956897"
  ]
}
''';

void main() {
  group('NominatimGeocoder (OpenStreetMap Free Provider)', () {
    test('getDataFromAddress returns parsed GeoData successfully', () async {
      final mockClient = MockHttpClient((request) async {
        expect(request.url.queryParameters['q'], 'Eiffel Tower');
        expect(request.url.queryParameters['format'], 'jsonv2');
        expect(request.headers['User-Agent'], isNotEmpty);
        return http.Response(sampleNominatimSearch, 200);
      });

      final geocoder = GeocoderPro.nominatim(client: mockClient);
      final result = await geocoder.getDataFromAddress('Eiffel Tower');

      expect(result, isNotNull);
      expect(result!.latitude, closeTo(48.8582, 0.001));
      expect(result.longitude, closeTo(2.2944, 0.001));
      expect(result.city, 'Paris');
      expect(result.country, 'France');
      expect(result.countryCode, 'FR');
      expect(result.postalCode, '75007');
      expect(result.street, 'Avenue Anatole France');
      expect(result.streetNumber, '5');
      expect(result.bounds, isNotNull);
      expect(result.bounds!.northeast.latitude, closeTo(48.8590, 0.001));
    });

    test(
      'getDataFromCoordinates returns parsed GeoData for reverse geocoding',
      () async {
        final mockClient = MockHttpClient((request) async {
          expect(request.url.queryParameters['lat'], '48.8582602');
          expect(request.url.queryParameters['lon'], '2.29449905431968');
          return http.Response(sampleNominatimReverse, 200);
        });

        final geocoder = GeocoderPro.openStreetMap(client: mockClient);
        final result = await geocoder.getDataFromCoordinates(
          latitude: 48.8582602,
          longitude: 2.29449905431968,
        );

        expect(result, isNotNull);
        expect(result!.city, 'Paris');
        expect(result.country, 'France');
        expect(result.countryCode, 'FR');
      },
    );

    test('handles 429 rate limit with QuotaExceededException', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('Too Many Requests', 429);
      });

      final geocoder = GeocoderPro.nominatim(client: mockClient);
      expect(
        () => geocoder.getDataFromAddress('Berlin'),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test(
      'fromAddress fallback resolves to Nominatim when apiKey is omitted',
      () async {
        final mockClient = MockHttpClient((request) async {
          return http.Response(sampleNominatimSearch, 200);
        });

        final result = await GeocoderPro.fromAddress(
          'Eiffel Tower',
          client: mockClient,
        );

        expect(result, isNotNull);
        expect(result!.city, 'Paris');
      },
    );

    test(
      'fromCoordinates fallback resolves to Nominatim when apiKey is omitted',
      () async {
        final mockClient = MockHttpClient((request) async {
          return http.Response(sampleNominatimReverse, 200);
        });

        final result = await GeocoderPro.fromCoordinates(
          latitude: 48.8582,
          longitude: 2.2944,
          client: mockClient,
        );

        expect(result, isNotNull);
        expect(result!.country, 'France');
      },
    );
  });
}
