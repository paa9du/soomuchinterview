import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAScreen extends StatefulWidget {
  const UserAScreen({super.key});

  @override
  _UserAScreenState createState() => _UserAScreenState();
}

class _UserAScreenState extends State<UserAScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isTripActive = false;
  String? _tripId;
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  int _tripDuration = 0;
  DateTime? _tripStartTime;
  Timer? _tripTimer;
  String _locationName = "Getting location...";
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _tripTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _updateLocationName(position.latitude, position.longitude);
      _mapController.move(LatLng(position.latitude, position.longitude), 13.0);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _updateLocationName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _locationName = "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      // Fallback to reverse geocoding API
      try {
        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['display_name'] as String?;
          if (address != null) {
            setState(() {
              _locationName = address;
            });
          }
        }
      } catch (e) {
        setState(() {
          _locationName = "Location unavailable";
        });
      }
    }
  }

  void _startTripTimer() {
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tripStartTime != null) {
        setState(() {
          _tripDuration = DateTime.now().difference(_tripStartTime!).inSeconds;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  Future<void> _startTrip() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    final tripDoc = _firestore.collection('trips').doc();
    _tripId = tripDoc.id;
    _tripStartTime = DateTime.now();

    // Get initial position
    Position initialPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await tripDoc.set({
      'startTime': _tripStartTime,
      'status': 'active',
      'userId': 'userA',
      'currentLocation': {
        'latitude': initialPosition.latitude,
        'longitude': initialPosition.longitude,
      },
      'lastUpdate': DateTime.now(),
    });

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          setState(() {
            _currentPosition = position;
          });

          // Update map
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            13.0,
          );
          _updateLocationName(position.latitude, position.longitude);

          // Update Firestore
          if (_tripId != null) {
            _firestore.collection('trips').doc(_tripId).update({
              'currentLocation': {
                'latitude': position.latitude,
                'longitude': position.longitude,
              },
              'lastUpdate': DateTime.now(),
            });
          }
        });

    setState(() {
      _isTripActive = true;
    });

    _startTripTimer();
  }

  Future<void> _stopTrip() async {
    _positionStream?.cancel();
    _positionStream = null;
    _tripTimer?.cancel();

    if (_tripId != null) {
      await _firestore.collection('trips').doc(_tripId).update({
        'endTime': DateTime.now(),
        'status': 'completed',
      });
    }

    setState(() {
      _isTripActive = false;
      _tripId = null;
      _tripDuration = 0;
      _tripStartTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User A - Trip Manager'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map Section (Top Half)
            Expanded(
              flex: 5,
              child: _currentPosition != null
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.soomuch',
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () => launchUrl(
                                Uri.parse(
                                  'https://openstreetmap.org/copyright',
                                ),
                              ),
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'Waiting for location...\nStart trip to see your location',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),

            // Info Section (Bottom Half)
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_isTripActive)
                        Column(
                          children: [
                            const Text(
                              'TRIP ACTIVE',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Duration: ${_formatDuration(_tripDuration)}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _locationName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (_currentPosition != null)
                              Column(
                                children: [
                                  _buildInfoRow(
                                    'Latitude',
                                    _currentPosition!.latitude.toStringAsFixed(
                                      6,
                                    ),
                                  ),
                                  _buildInfoRow(
                                    'Longitude',
                                    _currentPosition!.longitude.toStringAsFixed(
                                      6,
                                    ),
                                  ),
                                  _buildInfoRow(
                                    'Speed',
                                    '${_currentPosition!.speed.toStringAsFixed(1)} m/s',
                                  ),
                                  _buildInfoRow(
                                    'Accuracy',
                                    '${_currentPosition!.accuracy.toStringAsFixed(1)} meters',
                                  ),
                                ],
                              ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Ready to Start Trip',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _locationName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Press the button below to start sharing your location with User B',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isTripActive ? _stopTrip : _startTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTripActive
                                ? Colors.red
                                : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isTripActive ? 'STOP TRIP' : 'START TRIP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }
}
