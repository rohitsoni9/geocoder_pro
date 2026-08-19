import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder_pro/geocoder_pro.dart';

void main() {
  runApp(const GeocoderProExampleApp());
}

/// Root widget for Geocoder Pro example app.
class GeocoderProExampleApp extends StatelessWidget {
  const GeocoderProExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geocoder Pro Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade800),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const GeocoderHomeScreen(),
    );
  }
}

/// Main home screen showcasing Geocoder Pro capabilities.
class GeocoderHomeScreen extends StatefulWidget {
  const GeocoderHomeScreen({super.key});

  @override
  State<GeocoderHomeScreen> createState() => _GeocoderHomeScreenState();
}

enum GeocodeProviderType { openStreetMap, googleMaps }

class _GeocoderHomeScreenState extends State<GeocoderHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GeocodeProviderType _selectedProvider = GeocodeProviderType.openStreetMap;
  final TextEditingController _googleApiKeyController = TextEditingController();

  // Forward Geocoding State
  final TextEditingController _addressController = TextEditingController(
    text: 'Eiffel Tower, Paris',
  );
  List<GeoData> _forwardResults = [];
  bool _isForwardLoading = false;
  String? _forwardError;

  // Reverse Geocoding State
  final TextEditingController _latController = TextEditingController(
    text: '48.8584',
  );
  final TextEditingController _lngController = TextEditingController(
    text: '2.2945',
  );
  List<GeoData> _reverseResults = [];
  bool _isReverseLoading = false;
  String? _reverseError;

  // Spatial Utilities State
  final TextEditingController _pointALat = TextEditingController(
    text: '40.7128',
  );
  final TextEditingController _pointALng = TextEditingController(
    text: '-74.0060',
  ); // NYC
  final TextEditingController _pointBLat = TextEditingController(
    text: '51.5074',
  );
  final TextEditingController _pointBLng = TextEditingController(
    text: '-0.1278',
  ); // London
  double? _calculatedDistanceKm;
  double? _calculatedBearing;
  bool? _isWithin5000Km;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateDistance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _googleApiKeyController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _pointALat.dispose();
    _pointALng.dispose();
    _pointBLat.dispose();
    _pointBLng.dispose();
    super.dispose();
  }

  BaseGeocoder _getActiveGeocoder() {
    if (_selectedProvider == GeocodeProviderType.googleMaps) {
      final apiKey = _googleApiKeyController.text.trim();
      return GeocoderPro.google(apiKey: apiKey);
    } else {
      return GeocoderPro.nominatim();
    }
  }

  Future<void> _performForwardGeocode() async {
    final query = _addressController.text.trim();
    if (query.isEmpty) {
      _showSnackbar('Please enter an address to search');
      return;
    }

    if (_selectedProvider == GeocodeProviderType.googleMaps &&
        _googleApiKeyController.text.trim().isEmpty) {
      _showSnackbar('Please enter your Google Maps API Key');
      return;
    }

    setState(() {
      _isForwardLoading = true;
      _forwardError = null;
      _forwardResults = [];
    });

    try {
      final geocoder = _getActiveGeocoder();
      final results = await geocoder.getAddressesFromAddress(query);
      setState(() {
        _forwardResults = results;
        if (results.isEmpty) {
          _forwardError = 'No locations found for "$query"';
        }
      });
    } on GeocoderException catch (e) {
      setState(() {
        _forwardError = e.message;
      });
    } catch (e) {
      setState(() {
        _forwardError = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isForwardLoading = false;
      });
    }
  }

  Future<void> _performReverseGeocode() async {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lng == null) {
      _showSnackbar('Please enter valid numeric coordinates');
      return;
    }

    if (!GeoUtils.isValidCoordinates(lat, lng)) {
      _showSnackbar('Coordinates out of range (-90..90, -180..180)');
      return;
    }

    if (_selectedProvider == GeocodeProviderType.googleMaps &&
        _googleApiKeyController.text.trim().isEmpty) {
      _showSnackbar('Please enter your Google Maps API Key');
      return;
    }

    setState(() {
      _isReverseLoading = true;
      _reverseError = null;
      _reverseResults = [];
    });

    try {
      final geocoder = _getActiveGeocoder();
      final results = await geocoder.getAddressesFromCoordinates(
        latitude: lat,
        longitude: lng,
      );
      setState(() {
        _reverseResults = results;
        if (results.isEmpty) {
          _reverseError = 'No address found for ($lat, $lng)';
        }
      });
    } on GeocoderException catch (e) {
      setState(() {
        _reverseError = e.message;
      });
    } catch (e) {
      setState(() {
        _reverseError = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isReverseLoading = false;
      });
    }
  }

  void _calculateDistance() {
    final lat1 = double.tryParse(_pointALat.text.trim());
    final lon1 = double.tryParse(_pointALng.text.trim());
    final lat2 = double.tryParse(_pointBLat.text.trim());
    final lon2 = double.tryParse(_pointBLng.text.trim());

    if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
      setState(() {
        _calculatedDistanceKm = GeoUtils.distanceBetweenKm(
          lat1,
          lon1,
          lat2,
          lon2,
        );
        _calculatedBearing = GeoUtils.bearingBetween(lat1, lon1, lat2, lon2);
        _isWithin5000Km = GeoUtils.isWithinRadius(
          centerLatitude: lat1,
          centerLongitude: lon1,
          targetLatitude: lat2,
          targetLongitude: lon2,
          radiusInMeters: 5000000,
        );
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackbar('$label copied to clipboard');
  }

  void _showJsonModal(GeoData data) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Raw GeoData JSON',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(data.toMap()),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy JSON'),
                  onPressed: () {
                    _copyToClipboard(
                      const JsonEncoder.withIndent('  ').convert(data.toMap()),
                      'JSON payload',
                    );
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.travel_explore, size: 28),
            SizedBox(width: 10),
            Text('Geocoder Pro', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Forward'),
            Tab(icon: Icon(Icons.my_location), text: 'Reverse'),
            Tab(icon: Icon(Icons.straighten), text: 'Utilities'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProviderSelector(colorScheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildForwardTab(colorScheme),
                _buildReverseTab(colorScheme),
                _buildUtilitiesTab(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSelector(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Provider:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<GeocodeProviderType>(
                  segments: const [
                    ButtonSegment(
                      value: GeocodeProviderType.openStreetMap,
                      label: Text('OpenStreetMap (Free)'),
                      icon: Icon(Icons.public, size: 18),
                    ),
                    ButtonSegment(
                      value: GeocodeProviderType.googleMaps,
                      label: Text('Google Maps'),
                      icon: Icon(Icons.map, size: 18),
                    ),
                  ],
                  selected: {_selectedProvider},
                  onSelectionChanged: (set) {
                    setState(() {
                      _selectedProvider = set.first;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_selectedProvider == GeocodeProviderType.googleMaps) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _googleApiKeyController,
              decoration: const InputDecoration(
                labelText: 'Google Maps Geocoding API Key',
                hintText: 'AIzaSy...',
                prefixIcon: Icon(Icons.key),
                isDense: true,
              ),
              obscureText: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForwardTab(ColorScheme colorScheme) {
    final suggestedAddresses = [
      'Eiffel Tower, Paris',
      'Times Square, New York',
      'Sydney Opera House',
      'Tokyo Skytree',
      'Colosseum, Rome',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Convert Address to Coordinates',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address or Place Name',
                  hintText: 'e.g. 1600 Amphitheatre Pkwy, Mountain View',
                  prefixIcon: const Icon(Icons.location_city),
                  suffixIcon:
                      _addressController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(_addressController.clear),
                          )
                          : null,
                ),
                onSubmitted: (_) => _performForwardGeocode(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon:
                  _isForwardLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.search),
              onPressed: _isForwardLoading ? null : _performForwardGeocode,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children:
              suggestedAddresses.map((addr) {
                return ActionChip(
                  label: Text(addr, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _addressController.text = addr;
                    _performForwardGeocode();
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        if (_forwardError != null) _buildErrorCard(_forwardError!),
        if (_forwardResults.isNotEmpty) ...[
          Text(
            'Found ${_forwardResults.length} Result${_forwardResults.length > 1 ? 's' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._forwardResults.map(_buildResultCard),
        ],
      ],
    );
  }

  Widget _buildReverseTab(ColorScheme colorScheme) {
    final presets = [
      {'name': 'Paris', 'lat': '48.8584', 'lng': '2.2945'},
      {'name': 'New York', 'lat': '40.7128', 'lng': '-74.0060'},
      {'name': 'Tokyo', 'lat': '35.6762', 'lng': '139.6503'},
      {'name': 'London', 'lat': '51.5074', 'lng': '-0.1278'},
      {'name': 'Sydney', 'lat': '-33.8568', 'lng': '151.2153'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Convert Coordinates to Address',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: '48.8584',
                  prefixIcon: Icon(Icons.north),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: '2.2945',
                  prefixIcon: Icon(Icons.east),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children:
              presets.map((p) {
                return ActionChip(
                  avatar: const Icon(Icons.place, size: 16),
                  label: Text(p['name']!, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _latController.text = p['lat']!;
                    _lngController.text = p['lng']!;
                    _performReverseGeocode();
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon:
              _isReverseLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.pin_drop),
          label: const Text('Reverse Geocode'),
          onPressed: _isReverseLoading ? null : _performReverseGeocode,
        ),
        const SizedBox(height: 16),
        if (_reverseError != null) _buildErrorCard(_reverseError!),
        if (_reverseResults.isNotEmpty) ...[
          Text(
            'Found ${_reverseResults.length} Result${_reverseResults.length > 1 ? 's' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._reverseResults.map(_buildResultCard),
        ],
      ],
    );
  }

  Widget _buildUtilitiesTab(ColorScheme colorScheme) {
    final routePresets = [
      {
        'label': 'NYC ✈️ London',
        'lat1': '40.7128',
        'lon1': '-74.0060',
        'lat2': '51.5074',
        'lon2': '-0.1278',
      },
      {
        'label': 'Paris ✈️ Tokyo',
        'lat1': '48.8566',
        'lon1': '2.3522',
        'lat2': '35.6762',
        'lon2': '139.6503',
      },
      {
        'label': 'SF ✈️ LA',
        'lat1': '37.7749',
        'lon1': '-122.4194',
        'lat2': '34.0522',
        'lon2': '-118.2437',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Spatial Distance & Bearing Calculation',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children:
              routePresets.map((r) {
                return ActionChip(
                  label: Text(r['label']!),
                  onPressed: () {
                    _pointALat.text = r['lat1']!;
                    _pointALng.text = r['lon1']!;
                    _pointBLat.text = r['lat2']!;
                    _pointBLng.text = r['lon2']!;
                    _calculateDistance();
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Point A (Origin)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pointALat,
                        decoration: const InputDecoration(labelText: 'Lat A'),
                        onChanged: (_) => _calculateDistance(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _pointALng,
                        decoration: const InputDecoration(labelText: 'Lng A'),
                        onChanged: (_) => _calculateDistance(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Point B (Destination)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pointBLat,
                        decoration: const InputDecoration(labelText: 'Lat B'),
                        onChanged: (_) => _calculateDistance(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _pointBLng,
                        decoration: const InputDecoration(labelText: 'Lng B'),
                        onChanged: (_) => _calculateDistance(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_calculatedDistanceKm != null) ...[
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Distance (km)',
                        '${_calculatedDistanceKm!.toStringAsFixed(1)} km',
                        Icons.route,
                      ),
                      _buildStatColumn(
                        'Distance (miles)',
                        '${(_calculatedDistanceKm! * 0.621371).toStringAsFixed(1)} mi',
                        Icons.straighten,
                      ),
                      _buildStatColumn(
                        'Bearing',
                        '${_calculatedBearing!.toStringAsFixed(1)}°',
                        Icons.explore,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(
                        _isWithin5000Km == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            _isWithin5000Km == true
                                ? Colors.green
                                : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isWithin5000Km == true
                              ? 'Point B is within 5,000 km geofence radius of Point A'
                              : 'Point B is outside 5,000 km geofence radius of Point A',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatColumn(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(GeoData data) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_pin, color: colorScheme.primary, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.formattedAddress.isNotEmpty
                        ? data.formattedAddress
                        : data.address,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.code, size: 20),
                  tooltip: 'View JSON',
                  onPressed: () => _showJsonModal(data),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordinates',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${data.latitude.toStringAsFixed(6)}, ${data.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.coordinates.toDMS(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy Coordinates',
                  onPressed:
                      () => _copyToClipboard(
                        '${data.latitude}, ${data.longitude}',
                        'Coordinates',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (data.city.isNotEmpty)
                  _buildBadge(Icons.location_city, 'City: ${data.city}'),
                if (data.state.isNotEmpty)
                  _buildBadge(Icons.map, 'State: ${data.state}'),
                if (data.country.isNotEmpty)
                  _buildBadge(
                    Icons.flag,
                    'Country: ${data.country} (${data.countryCode})',
                  ),
                if (data.postalCode.isNotEmpty)
                  _buildBadge(
                    Icons.markunread_mailbox,
                    'Postal: ${data.postalCode}',
                  ),
                if (data.street.isNotEmpty)
                  _buildBadge(Icons.signpost, 'Street: ${data.street}'),
                if (data.subLocality.isNotEmpty)
                  _buildBadge(Icons.home_work, 'Area: ${data.subLocality}'),
                if (data.locationType.isNotEmpty)
                  _buildBadge(Icons.gps_fixed, 'Type: ${data.locationType}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
