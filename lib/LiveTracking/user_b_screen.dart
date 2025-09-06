import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class UserBScreen extends StatefulWidget {
  const UserBScreen({super.key});

  @override
  _UserBScreenState createState() => _UserBScreenState();
}

class _UserBScreenState extends State<UserBScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MapController _mapController = MapController();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tripSubscription;
  bool _isTripActive = false;
  Map<String, dynamic>? _tripData;
  Timer? _updateTimer;
  String _locationName = "Waiting for location...";
  String _errorMessage = '';
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _listenToActiveTrip();
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
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

  // void _listenToActiveTrip() {
  //   print("User B: Starting to listen for active trips");
  //   setState(() {
  //     _debugInfo = 'Listening for active trips...';
  //   });
  //
  //   _tripSubscription = _firestore
  //       .collection('trips')
  //       .where('status', isEqualTo: 'active')
  //       .snapshots()
  //       .listen(
  //         (QuerySnapshot<Map<String, dynamic>> snapshot) {
  //           print(
  //             "User B: Received snapshot with ${snapshot.docs.length} active trips",
  //           );
  //           setState(() {
  //             _debugInfo = 'Found ${snapshot.docs.length} active trips';
  //           });
  //
  //           if (snapshot.docs.isNotEmpty) {
  //             final tripDoc = snapshot.docs.first;
  //             final tripData = tripDoc.data();
  //             print("User B: Found active trip: $tripData");
  //
  //             setState(() {
  //               _isTripActive = true;
  //               _tripData = tripData;
  //               _errorMessage = '';
  //             });
  //
  //             // Check for location data
  //             if (_tripData != null && _tripData!['currentLocation'] != null) {
  //               final locationData =
  //                   _tripData!['currentLocation'] as Map<String, dynamic>;
  //               print("User B: Location data: $locationData");
  //
  //               // Extract latitude and longitude correctly
  //               final double lat = (locationData['latitude'] as num).toDouble();
  //               final double lng = (locationData['longitude'] as num)
  //                   .toDouble();
  //
  //               print("User B: Lat: $lat, Lng: $lng");
  //
  //               // Update map and location name
  //               _mapController.move(LatLng(lat, lng), 13.0);
  //               _updateLocationName(lat, lng);
  //             } else {
  //               print(
  //                 "User B: No currentLocation found yet. Waiting for updates...",
  //               );
  //               setState(() {
  //                 _errorMessage = 'Waiting for User A\'s location data...';
  //               });
  //
  //               // Listen for updates to this specific document
  //               _listenToTripUpdates(tripDoc.id);
  //             }
  //           } else {
  //             print("User B: No active trips found");
  //             setState(() {
  //               _isTripActive = false;
  //               _tripData = null;
  //               _errorMessage =
  //                   'No active trips found. Ask User A to start a trip.';
  //             });
  //           }
  //         },
  //         onError: (error) {
  //           print("User B: Error listening to trips: $error");
  //           setState(() {
  //             _errorMessage = 'Error: $error';
  //           });
  //         },
  //       );
  // }
  void _listenToActiveTrip() {
    print("User B: Starting to listen for active trips");
    setState(() {
      _debugInfo = 'Listening for active trips...';
    });

    _tripSubscription = _firestore
        .collection('trips')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            print(
              "User B: Received snapshot with ${snapshot.docs.length} active trips",
            );
            setState(() {
              _debugInfo = 'Found ${snapshot.docs.length} active trips';
            });

            if (snapshot.docs.isNotEmpty) {
              // Find the first trip that actually has location data
              DocumentSnapshot<Map<String, dynamic>>? tripWithLocation;

              for (final tripDoc in snapshot.docs) {
                final tripData = tripDoc.data();
                if (tripData != null && tripData['currentLocation'] != null) {
                  tripWithLocation = tripDoc;
                  break;
                }
              }

              if (tripWithLocation != null) {
                final tripData = tripWithLocation.data()!;
                print("User B: Found trip with location data: $tripData");

                setState(() {
                  _isTripActive = true;
                  _tripData = tripData;
                  _errorMessage = '';
                });

                final locationData =
                    _tripData!['currentLocation'] as Map<String, dynamic>;
                final double lat = (locationData['latitude'] as num).toDouble();
                final double lng = (locationData['longitude'] as num)
                    .toDouble();

                print("User B: Lat: $lat, Lng: $lng");

                // Update map and location name
                _mapController.move(LatLng(lat, lng), 13.0);
                _updateLocationName(lat, lng);
              } else {
                print("User B: No trips with location data found");
                setState(() {
                  _isTripActive = true; // Trip is active but no location yet
                  _errorMessage = 'Trip found but waiting for location data...';
                });

                // Listen to the first trip for updates
                _listenToTripUpdates(snapshot.docs.first.id);
              }
            } else {
              print("User B: No active trips found");
              setState(() {
                _isTripActive = false;
                _tripData = null;
                _errorMessage =
                    'No active trips found. Ask User A to start a trip.';
              });
            }
          },
          onError: (error) {
            print("User B: Error listening to trips: $error");
            setState(() {
              _errorMessage = 'Error: $error';
            });
          },
        );
  }

  // Add this new method to listen for updates to a specific trip
  void _listenToTripUpdates(String tripId) {
    // Cancel any previous update listener
    _updateTimer?.cancel();

    // Set up a listener for this specific trip document
    _firestore
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .listen(
          (documentSnapshot) {
            if (documentSnapshot.exists) {
              final updatedData = documentSnapshot.data();
              print("User B: Trip updated: $updatedData");

              if (updatedData != null &&
                  updatedData['currentLocation'] != null) {
                final locationData =
                    updatedData['currentLocation'] as Map<String, dynamic>;
                final double lat = (locationData['latitude'] as num).toDouble();
                final double lng = (locationData['longitude'] as num)
                    .toDouble();

                print("User B: Location received! Lat: $lat, Lng: $lng");

                setState(() {
                  _tripData = updatedData;
                  _errorMessage = '';
                });

                // Update map and location name
                _mapController.move(LatLng(lat, lng), 13.0);
                _updateLocationName(lat, lng);
              }
            }
          },
          onError: (error) {
            print("User B: Error listening to trip updates: $error");
          },
        );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'N/A';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(DateTime? startTime) {
    if (startTime == null) return 'N/A';
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        _tripData != null && _tripData!['currentLocation'] != null;
    final double? lat = hasLocation
        ? (_tripData!['currentLocation']['latitude'] as num).toDouble()
        : null;
    final double? lng = hasLocation
        ? (_tripData!['currentLocation']['longitude'] as num).toDouble()
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User B - Live Location Viewer'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Debug Info
            if (_debugInfo.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.blue[50],
                child: Text(
                  _debugInfo,
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.red[50],
                child: Text(
                  _errorMessage,
                  style: TextStyle(fontSize: 14, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // Map Section
            Expanded(
              flex: 7,
              child: hasLocation
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(lat!, lng!),
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
                              point: LatLng(lat, lng),
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
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 40,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No Active Trip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'User A has not started a trip yet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Info Panel
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: _isTripActive
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'LIVE TRACKING ACTIVE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            Text(
                              _locationName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),

                            if (_tripData != null)
                              Column(
                                children: [
                                  _buildInfoRow(
                                    'Trip Started',
                                    _formatTime(
                                      _tripData!['startTime']?.toDate(),
                                    ),
                                  ),
                                  _buildInfoRow(
                                    'Duration',
                                    _formatDuration(
                                      _tripData!['startTime']?.toDate(),
                                    ),
                                  ),
                                  if (hasLocation)
                                    Column(
                                      children: [
                                        _buildInfoRow(
                                          'Latitude',
                                          lat!.toStringAsFixed(6),
                                        ),
                                        _buildInfoRow(
                                          'Longitude',
                                          lng!.toStringAsFixed(6),
                                        ),
                                      ],
                                    ),
                                  if (_tripData!['lastUpdate'] != null)
                                    _buildInfoRow(
                                      'Last Update',
                                      _formatTime(
                                        _tripData!['lastUpdate']?.toDate(),
                                      ),
                                    ),
                                ],
                              ),

                            const SizedBox(height: 10),
                            const LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_searching,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Waiting for User A to start a trip',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _locationName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}
