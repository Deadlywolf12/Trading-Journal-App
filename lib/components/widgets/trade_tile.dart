import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tj/components/Configurations/theme.dart';

class TradesList extends StatelessWidget {
  final String coinName;
  final Function(String tradeId) onEditTrade;

  const TradesList({
    Key? key,
    required this.coinName,
    required this.onEditTrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('trades')
          .where('coin', isEqualTo: coinName)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No trades found for this coin."));
        }

        final trades = snapshot.data!.docs;

        return ListView.builder(
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            final tradeId = trade.id;
            final tradeType = trade['type'];
            final usd = trade['usd'];
            final price = trade['price'];
            final amount = trade['amount'];
            final timestamp = trade['date'] as Timestamp;
            final formattedDate =
                DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text("Trade Type: $tradeType"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Amount: $amount"),
                    Text("Price: $price"),
                    Text("USD Value: $usd"),
                    Text("Date: $formattedDate"),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: AppTheme.errorColor,
                  ),
                  onPressed: () => onEditTrade(tradeId),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
