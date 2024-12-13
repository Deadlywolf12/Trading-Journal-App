import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/pages/market_page.dart';
import 'package:tj/components/widgets/textfield.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usdtController = TextEditingController();
  bool isLoading = false;
  bool isLoading2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.blackColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Set your total USDT quota to invest:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: "Total USDT",
              icon: const Icon(Icons.local_atm_sharp),
              inputType: TextInputType.number,
              controller: _usdtController,
            ),
            const SizedBox(height: 20),

            // Update button
            ElevatedButton(
              onPressed: _updateUSDT,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 90.0),
                backgroundColor: AppTheme.primaryColor,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: AppTheme.blackColor)
                  : const Text(
                      'Update',
                      style:
                          TextStyle(fontSize: 18, color: AppTheme.blackColor),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmReset(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 90.0),
                backgroundColor: AppTheme.errorColor,
              ),
              child: isLoading2
                  ? const CircularProgressIndicator(
                      color: AppTheme.blackColor,
                    )
                  : const Text(
                      'Reset',
                      style:
                          TextStyle(fontSize: 18, color: AppTheme.blackColor),
                    ),
            ),
            const SizedBox(height: 20),

            // Logout button
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 90.0),
                  backgroundColor: AppTheme.primaryColor),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 18, color: AppTheme.blackColor),
              ),
            ),

            // Reset button
          ],
        ),
      ),
    );
  }

  // Update USDT in Firestore
  Future<void> _updateUSDT() async {
    if (_usdtController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid amount of USDT."),
      ));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User not logged in.");
      }

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await userDocRef.update({
        'usdToInvest': double.parse(_usdtController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("USDT quota updated successfully!"),
      ));

      _usdtController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating USDT: $e"),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show confirmation dialog before resetting data
  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text(
              "This action cannot be undone. All coins, trades, and data will be permanently deleted."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _resetData();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor),
              child: const Text(
                "Reset",
                style: TextStyle(color: AppTheme.blackColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Reset data for the user
  Future<void> _resetData() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("User not logged in."),
      ));
      return;
    }

    try {
      setState(() {
        isLoading2 = true;
      });

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Delete all documents in the 'coins' collection
      final coinsSnapshot = await userDocRef.collection('coins').get();
      for (var doc in coinsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all documents in the 'trades' collection
      final tradesSnapshot = await userDocRef.collection('trades').get();
      for (var doc in tradesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Reset user fields
      await userDocRef.update({
        'usdToInvest': 0.0,
        'invested': 0.0,
        'profit': 0.0,
        'loss': 0.0,
        'remaining': 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Data reset successfully!"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error resetting data: $e"),
      ));
    } finally {
      setState(() {
        isLoading2 = false;
      });
    }
  }

  // Logout user
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Logged out successfully!"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error logging out: $e"),
      ));
    }
  }
}
