import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCoinDialog extends StatefulWidget {
  @override
  _AddCoinDialogState createState() => _AddCoinDialogState();
}

class _AddCoinDialogState extends State<AddCoinDialog> {
  final _coinNameController = TextEditingController();
  bool _isLoading = false;

  // Function to add a new coin to Firestore
  Future<void> addCoin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final coinName = _coinNameController.text.trim();

      if (uid != null && coinName.isNotEmpty) {
        // Query the Firestore to check if the coin already exists
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('coins')
            .where('coin', isEqualTo: coinName)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // If the coin already exists, show a warning message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$coinName already exists in your collection!'),
            backgroundColor: Colors.red, // Optional: Red for warning
          ));
        } else {
          // Add the new coin to the "coins" collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('coins')
              .add({
            'coin': coinName,
            'avgCost': 0,
            'invest': 0,
            'totalCoins': 0,
            'profit': 0,
          });

          // Show a success message and close the dialog
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$coinName added successfully!'),
          ));

          // Clear the input field
          _coinNameController.clear();
          Navigator.of(context).pop();
        }
      } else {
        // If no coin name is entered
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a coin name.'),
        ));
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add coin: $e'),
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Coin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _coinNameController,
            decoration: const InputDecoration(
              labelText: 'Coin Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        // Add Button
        TextButton(
          onPressed: _isLoading ? null : addCoin, // Disable while loading
          child: _isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              : const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _coinNameController.dispose();
    super.dispose();
  }
}
