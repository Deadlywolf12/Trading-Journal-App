import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateCoinWithTradeTotals(String coinName) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw Exception("User is not logged in.");
  }

  try {
    // Fetch trades for the specific coin
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('trades')
        .where('coin', isEqualTo: coinName)
        .get();

    double totalAmount = 0.0; // Net coin amount (Buy adds, Sell subtracts)
    double totalInvestment = 0.0; // Total investment only for 'Buy' trades
    double avgCost = 0.0; // Average cost per coin

    for (var doc in querySnapshot.docs) {
      final tradeData = doc.data();
      final double amount =
          double.tryParse(tradeData['amount'].toString()) ?? 0.0;
      final double usdValue =
          double.tryParse(tradeData['usd'].toString()) ?? 0.0;
      final String tradeType =
          tradeData['type'] ?? ''; // Example: 'Buy' or 'Sell'

      if (tradeType == 'Buy') {
        totalAmount += amount;
        totalInvestment += usdValue;
      } else if (tradeType == 'Sell') {
        totalAmount -= amount; // Subtract sold coins
        totalInvestment -= usdValue;
      }
    }

    if (totalAmount > 0) {
      avgCost = totalInvestment / totalAmount;
    }

    // Fetch the coin document(s) matching the coin name
    final coinQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('coins')
        .where('coin', isEqualTo: coinName)
        .get();

    if (coinQuerySnapshot.docs.isNotEmpty) {
      for (var coinDoc in coinQuerySnapshot.docs) {
        // Update the matched coin document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('coins')
            .doc(coinDoc.id)
            .update({
          'totalCoins': totalAmount,
          'invest': totalInvestment,
          'avgCost': avgCost,
        });
        print("Updated coin doc: ${coinDoc.id}");
      }
    } else {
      print("No matching coin documents found for $coinName.");
    }
  } catch (e) {
    throw Exception("Error updating coin totals: $e");
  }
}
