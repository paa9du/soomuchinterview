import 'package:flutter/material.dart';
import 'package:soomuch/LiveTracking/user_a_screen.dart';
import 'package:soomuch/LiveTracking/user_b_screen.dart';

class LocationSharingApp extends StatelessWidget {
  const LocationSharingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Sharing',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserSelectionScreen(),
    );
  }
}

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserAScreen()),
                );
              },
              child: const Text('User A (Sharer)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserBScreen()),
                );
              },
              child: const Text('User B (Viewer)'),
            ),
          ],
        ),
      ),
    );
  }
}
