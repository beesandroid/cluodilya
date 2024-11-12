import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // Import Lottie package

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Build the MaterialApp.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Bus Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ViewLocationsPage(),
    );
  }
}

/// A StatefulWidget that displays the map and tracks bus locations.
class ViewLocationsPage extends StatefulWidget {
  const ViewLocationsPage({Key? key}) : super(key: key);

  @override
  _ViewLocationsPageState createState() => _ViewLocationsPageState();
}

class _ViewLocationsPageState extends State<ViewLocationsPage> {
  late MapController controller;
  Timer? _timer;
  GeoPoint? _busLocation; // To keep track of the bus location
  bool _isLoading = false;

  final String apiUrl =
      'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BusTrackDisplay';
  final Duration fetchInterval = const Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    controller = MapController(
      initMapWithUserPosition: UserTrackingOption(
        enableTracking: false,
        unFollowUser: false,
      ),
    );
    _startFetchingLocations();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    controller.dispose(); // Dispose the controller
    super.dispose();
  }
  void _startFetchingLocations() {
    _fetchLocationsFromAPI();
    _timer = Timer.periodic(fetchInterval, (timer) {
      _fetchLocationsFromAPI();
    });
  }

  Future<void> _fetchLocationsFromAPI() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> requestBody = {
      "grpCode": "beesdev",
      "colCode": "0001",
      "collegeId": 1
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse the response as a Map since it's a single location object
        Map<String, dynamic> data = jsonDecode(response.body);
        print(data);

        // Check if the necessary data exists in the response
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          double? latitude = _parseDouble(data['latitude']);
          double? longitude = _parseDouble(data['longitude']);

          if (latitude != null &&
              longitude != null &&
              latitude != 0.0 &&
              longitude != 0.0) {
            GeoPoint location = GeoPoint(
              latitude: latitude,
              longitude: longitude,
            );

            // Update the marker on the map
            await _updateBusMarker(location);
          } else {
            _showSnackBar("Invalid latitude or longitude values received.");
          }
        } else {
          _showSnackBar("Required location data is missing from the response.");
        }
      } else {
        _showSnackBar(
            "Failed to fetch location. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Error fetching location: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Parses dynamic values to double.
  double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Builds a custom marker widget that displays the bus icon and bus number.
  Widget _buildBusMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons8-bus-100.png',
          width: 48,
          height: 48,
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'TS 08 GU 7169',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateBusMarker(GeoPoint newLocation) async {
    try {
      if (_busLocation != null) {
        await controller.removeMarker(_busLocation!);
      }
      await controller.addMarker(
        newLocation,
        markerIcon: MarkerIcon(
          iconWidget: _buildBusMarker(),
        ),
      );
      _busLocation = newLocation;
      await controller.goToLocation(newLocation);
    } catch (e) {
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OSMFlutter Map Widget
          OSMFlutter(
            controller: controller,
            osmOption: OSMOption(
              zoomOption: ZoomOption(
                initZoom: 14,
                minZoomLevel: 3,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),
              markerOption: MarkerOption(
                defaultMarker: MarkerIcon(
                  icon: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 56,
                  ),
                ),
              ),
            ),
            mapIsLoading: Center(
              child: Lottie.asset(
                'assets/busAnime.json',
                width: 250,
                height: 250,
                repeat: false,
              ),
            ),
          ),
          // Loading Indicator for fetching locations
        ],
      ),
    );
  }
}
