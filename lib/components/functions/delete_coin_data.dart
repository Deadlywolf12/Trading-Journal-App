import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> handleDeleteByCoinName(
    BuildContext context, String coinName) async {
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
  final tradesCollectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('trades');

  // Show confirmation dialog
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text(
          "Are you sure you want to delete $coinName? "
          "This will delete all its trades and cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel deletion
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Confirm deletion
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
    // Start the deletion process
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Deleting coin and related trades...")),
    );

    // Query the `coins` collection to find and delete the coin by its name
    final coinSnapshot =
        await coinsCollectionRef.where('coin', isEqualTo: coinName).get();
    for (var doc in coinSnapshot.docs) {
      await doc.reference.delete();
    }

    // Query and delete all trades related to this coin
    final tradesSnapshot =
        await tradesCollectionRef.where('coin', isEqualTo: coinName).get();
    for (var doc in tradesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$coinName and its trades have been deleted.")),
    );
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error deleting $coinName: $e")),
    );
  }
}
