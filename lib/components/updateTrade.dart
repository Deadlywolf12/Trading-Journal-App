import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateTotalInvestByCoinName(String? coinName, double newInvestment,
    double newCoins, String? tradeType) async {
  try {
    // Get the current user's UID
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    // Reference to the user's coins collection
    final CollectionReference coinsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('coins');

    // Query for the document where 'coin' matches the given coinName
    final QuerySnapshot querySnapshot =
        await coinsCollection.where('coin', isEqualTo: coinName).get();

    final DocumentSnapshot coinDoc = querySnapshot.docs.first;

    final data = coinDoc.data() as Map<String, dynamic>;
    final double currentTotalInvest = data['invest']?.toDouble() ?? 0.0;
    final double currentCoins = data['totalCoins']?.toDouble() ?? 0.0;
    final double avgCost = data['avgCost']?.toDouble() ?? 0.0;
    final double profit = data['profit']?.toDouble() ?? 0.0;

    if (tradeType != null && tradeType.toLowerCase() == 'buy') {
      // Calculate the new totalInvest value
      final double updatedTotalInvest = currentTotalInvest + newInvestment;
      final double updatedCoins = currentCoins + newCoins;
      final double updatedAvgCost =
          updatedCoins > 0 ? updatedTotalInvest / updatedCoins : 0.0;

      // Update the document with the new totalInvest value
      await coinDoc.reference.update({
        'invest': updatedTotalInvest,
        'totalCoins': updatedCoins,
        'avgCost': updatedAvgCost,
      });
      calculateAndUpdateUserData();
    } else if (tradeType != null && tradeType.toLowerCase() == 'sell') {
      //if trade type is sell
      final double totalSold = avgCost * newCoins;
      final double updatedTotalInvest2 = currentTotalInvest - totalSold;
      final double updatedCoins2 = currentCoins - newCoins;

      final double profitOnTrade = newInvestment - totalSold;
      final double updatedProfit = profit + profitOnTrade;

      await coinDoc.reference.update({
        'invest': updatedTotalInvest2,
        'totalCoins': updatedCoins2,
        'profit': updatedProfit,
      });
      calculateAndUpdateUserData();
    } else {}
  } catch (e) {}
}

Future<bool> isSellValid(String? coin, double amtToSell, tradeType) async {
  try {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User is not logged in.");
    if (tradeType == "Sell") {
      // Reference to the user's coins collection
      final CollectionReference coinsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('coins');

      // Query for the document where 'coin' matches the given coinName
      final QuerySnapshot querySnapshot =
          await coinsCollection.where('coin', isEqualTo: coin).get();
      final DocumentSnapshot coinDoc = querySnapshot.docs.first;

      final data = coinDoc.data() as Map<String, dynamic>;
      final double totalAmount = data['totalCoins']?.toDouble();

      if (totalAmount >= amtToSell) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  } catch (e) {
    return false;
  }
}

Future<void> calculateAndUpdateUserData() async {
  try {
    // Get the current user's UID
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in.");
    }

    // Reference to the user's document
    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    // Fetch user data
    final DocumentSnapshot<Object?> userData = await userDocRef.get();

    // Calculate the totals for profit, loss, and investment
    double totalInvestment = 0.0;
    double totalProfit = 0.0;
    double totalLoss = 0.0;

    // Fetch the user's coins collection
    final CollectionReference coinsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('coins');
    final QuerySnapshot querySnapshot = await coinsCollection.get();

    // Process each coin to calculate total investment, profit, and loss
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final double invest = (data['invest'] as num?)?.toDouble() ?? 0.0;
      final double profit = (data['profit'] as num?)?.toDouble() ?? 0.0;

      totalInvestment += invest;

      if (profit >= 0) {
        totalProfit += profit;
      } else {
        totalLoss += profit.abs();
      }
    }

    // Update the user's document with the calculated values
    await userDocRef.update({
      'invested': totalInvestment,
      'profit': totalProfit,
      'loss': totalLoss,
    });

    // ignore: empty_catches
  } catch (e) {}
}
