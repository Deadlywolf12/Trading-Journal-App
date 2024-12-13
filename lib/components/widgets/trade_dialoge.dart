import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';

import 'package:tj/components/updateTrade.dart';

class EditTradeDialog extends StatefulWidget {
  final String tradeId;

  const EditTradeDialog({Key? key, required this.tradeId}) : super(key: key);

  @override
  _EditTradeDialogState createState() => _EditTradeDialogState();
}

class _EditTradeDialogState extends State<EditTradeDialog> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _usdController = TextEditingController();
  double totalAmount = 00;
  String? tradeType = 'Buy';
  bool isLoading = false;
  String _coinName = "";

  @override
  void initState() {
    super.initState();
    _loadTradeData();
  }

  void _loadTradeData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final trade = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('trades')
        .doc(widget.tradeId)
        .get();

    if (trade.exists) {
      final data = trade.data()!;

      setState(() {
        totalAmount = data['amount'];
        _priceController.text = data['price'].toString();
        _usdController.text = data['usd'].toString();
        tradeType = data['type'].toString();
        _coinName = data['coin'].toString();
      });
    }
  }

  void _deleteTradeAndUpdateCoin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in')),
      );
      return;
    }

    try {
      // Fetch the trade document to get its values
      final tradeDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('trades')
          .doc(widget.tradeId)
          .get();

      if (!tradeDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade not found')),
        );
        return;
      }

      final tradeData = tradeDoc.data();
      if (tradeData == null) return;

      // Extract trade values
      final double amount =
          double.tryParse(tradeData['amount'].toString()) ?? 0.0;
      final double usdValue =
          double.tryParse(tradeData['usd'].toString()) ?? 0.0;
      final String tradeType = tradeData['type'] ?? ''; // 'Buy' or 'Sell'
      final String coinName = tradeData['coin'] ?? '';

      // Delete the trade document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('trades')
          .doc(widget.tradeId)
          .delete();

      // Update the coin collection
      final coinQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('coins')
          .where('coin', isEqualTo: coinName)
          .get();

      if (coinQuerySnapshot.docs.isNotEmpty) {
        for (var coinDoc in coinQuerySnapshot.docs) {
          final coinData = coinDoc.data();
          final double totalCoins =
              double.tryParse(coinData['totalCoins'].toString()) ?? 0.0;
          final double totalInvestment =
              double.tryParse(coinData['invest'].toString()) ?? 0.0;
          final double avgCost =
              double.tryParse(coinData['avgCost'].toString()) ?? 0.0;
          final double profit =
              double.tryParse(coinData['profit'].toString()) ?? 0.0;

          double newTotalCoins = totalCoins;
          double newTotalInvestment = totalInvestment;
          double newProfit = 0;
          double newAvgCost = 0;

          if (tradeType == 'Buy') {
            // Subtract coins and investment for a Buy trade
            newTotalCoins -= amount;
            newTotalInvestment -= usdValue;
            newAvgCost =
                newTotalCoins > 0 ? newTotalInvestment / newTotalCoins : 0.0;
          } else if (tradeType == 'Sell') {
            // Add coins back and increase investment for a Sell trade
            newTotalCoins += amount;
            newAvgCost = avgCost;

            double getProfit = amount * avgCost;
            newProfit = profit - getProfit;
            newTotalInvestment += usdValue;
            newTotalInvestment -= getProfit;
          }

          // Update the coin document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('coins')
              .doc(coinDoc.id)
              .update({
            'totalCoins': newTotalCoins,
            'invest': newTotalInvestment,
            'avgCost': newAvgCost,
            'profit': newProfit,
          });
        }
      }
      calculateAndUpdateUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trade deleted and coin data updated')),
      );

      Navigator.pop(context); // Close the dialog or screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Trade"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Are you sure you want to delete trade? "
            "This will delete all its trades and cannot be undone.",
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            _deleteTradeAndUpdateCoin();

            Navigator.of(context).pop();

            setState(() {
              isLoading = false;
            });
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
      ],
    );
  }
}
