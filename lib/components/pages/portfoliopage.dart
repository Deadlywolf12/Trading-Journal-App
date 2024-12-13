import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/functions/delete_coin_data.dart';
import 'package:tj/components/functions/reset_coin_data.dart';
import 'package:tj/components/widgets/add_Trade.dart';
import 'package:tj/components/widgets/add_coin.dart';
import 'package:tj/components/widgets/coin_tile.dart';
import 'package:tj/components/pages/coins_detail.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trades"),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.blackColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                _showAddDialog(context);
              },
              child: const Icon(Icons.add),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection("coins")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error fetching data"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No data available"),
            );
          }

          final dataDocs = snapshot.data!.docs;
          final filteredDocs = searchQuery.isEmpty
              ? dataDocs // Show all coins if searchQuery is empty
              : dataDocs.where((doc) {
                  final title = doc['coin']?.toString().toLowerCase() ?? '';
                  return title.contains(searchQuery.toLowerCase());
                }).toList();

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data() as Map<String, dynamic>;
              final title = data['coin'] ?? 'No Title';
              final cost = '${data['avgCost'] ?? 0}';
              final investment = '${data['invest'] ?? 0}';
              final profit = '${data['profit'] ?? 0}';
              final totalCoins = '${data['totalCoins'] ?? 0}';

              return CoinTile(
                title: title,
                cost: cost,
                investment: investment,
                icon: Icons.wysiwyg_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoinDetailsPage(
                        coinName: title, // Pass the coin name
                        cost: cost,
                        investment: investment,
                        profit: profit,
                        totalCoins: totalCoins,
                      ),
                    ),
                  );
                },
                profit: profit,
                totalCoins: totalCoins,
                onDelete: () {
                  handleDeleteByCoinName(context, title);
                },
                onReset: () {
                  handleResetCoinData(context, title);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to show search dialog
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search Coin"),
          content: TextField(
            controller: TextEditingController(text: searchQuery),
            onChanged: (query) {
              setState(() {
                searchQuery = query; // Update the search query
              });
            },
            decoration: const InputDecoration(hintText: "Enter coin name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Reset"),
              onPressed: () {
                setState(() {
                  searchQuery = ''; // Reset the search query
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add Coin'),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => AddCoinDialog(),
                );
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => TradeDialog(),
                );
              },
              child: const Text("Add Trade"),
            ),
          ],
        );
      },
    );
  }
}
