// lib/widgets/firebase_status_banner.dart
// Displays a small banner showing whether Firebase Firestore is connected

import 'package:flutter/material.dart';

enum FirebaseStatus { checking, connected, error }

class FirebaseStatusBanner extends StatelessWidget {
  final FirebaseStatus status;

  const FirebaseStatusBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == FirebaseStatus.connected) {
      // Show a subtle green pill when connected
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Firebase connected',
              style: TextStyle(color: Colors.greenAccent, fontSize: 11),
            ),
          ],
        ),
      );
    }

    if (status == FirebaseStatus.error) {
      // Show a warning bar when Firestore is not reachable
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Firebase not connected. Check Firestore rules or network.',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Checking state - tiny animated indicator
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Checking Firebase...',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
