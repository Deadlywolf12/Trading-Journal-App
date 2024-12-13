import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> handleResetCoinData(BuildContext context, String coinName) async {
  final uid = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

  if (uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in.")),
    );
    return;
  }

  final coinsCollectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('coins');

  // Show confirmation dialog
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Reset"),
        content: Text(
          "Are you sure you want to reset all data for $coinName? "
          "This will reset its Avg cost, Total Coins, and Investment to 0.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel reset
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Confirm reset
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );

  // If user cancels, exit
  if (confirmed == null || !confirmed) {
    return;
  }

  try {
    // Start the reset process
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resetting coin data...")),
    );

    // Query the `coins` collection to find the specific coin by name
    final coinSnapshot =
        await coinsCollectionRef.where('coin', isEqualTo: coinName).get();

    if (coinSnapshot.docs.isNotEmpty) {
      final coinDoc = coinSnapshot.docs.first;

      // Reset the fields
      await coinDoc.reference.update({
        'avgCost': 0.0,
        'totalCoins': 0.0,
        'invest': 0.0,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$coinName has been reset successfully.")),
      );
    } else {
      // Coin not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Coin $coinName not found.")),
      );
    }
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error resetting $coinName: $e")),
    );
  }
}
