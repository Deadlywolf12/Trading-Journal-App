import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tj/components/updateTrade.dart';
import 'package:tj/components/widgets/dialogue.dart';

class TradeDialog extends StatefulWidget {
  @override
  _TradeDialogState createState() => _TradeDialogState();
}

class _TradeDialogState extends State<TradeDialog> {
  String? selectedCoin; // Holds the selected coin from the dropdown
  String? selectedTradeType = 'Buy'; // Default to 'Buy'
  final TextEditingController _investedController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  double totalAmount = 0.0;

  List<String> coins = []; // List of coins fetched from Firestore
  bool isLoading = true;
  bool isLoading2 = false;

  @override
  void initState() {
    super.initState();
    fetchCoinsFromDatabase();
  }

  // Function to add a new coin to Firestore
  Future<void> addTrade() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final inst = FirebaseFirestore.instance;
      final currentDate = Timestamp.now();

      // Add the new coin to the "coins" collection under the user's document
      await inst.collection('users').doc(uid).collection('trades').add({
        'coin': selectedCoin,
        'type': selectedTradeType,
        'usd': _investedController.text.trim(),
        'price': _priceController.text.trim(),
        'amount': totalAmount,
        'date': currentDate,
      });

      // Show a success message and close the dialog
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Trade added successfully!'),
      ));

      // Clear the input field
      _investedController.clear();
      _priceController.clear();

      Navigator.of(context).pop();
    } catch (e) {
      showErrorDialog(context, 'Failed to add coin: $e');
    }

    setState(() {
      isLoading2 = false;
    });
  }

  Future<void> fetchCoinsFromDatabase() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      // Fetch the list of coins from the 'coins' collection
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection("coins")
          .get();

      // Extract the names of the coins and update the state
      final List<String> fetchedCoins = querySnapshot.docs
          .map((doc) => doc['coin']
              as String) // Assuming the coin name is stored in 'name'
          .toList();

      setState(() {
        coins = fetchedCoins;
        isLoading = false; // Data is loaded
      });
    } catch (e) {
      // Handle any errors while fetching data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch coins: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateTotal() {
    // Get values from text fields
    final double invested = double.tryParse(_investedController.text) ?? 0.0;
    final double price = double.tryParse(_priceController.text) ?? 0.0;

    // Calculate the total amount
    setState(() {
      totalAmount =
          invested / (price > 0 ? price : 1); // Prevent division by zero
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Trade"),
      content: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown Menu for Coins
                  DropdownButtonFormField<String>(
                    value: selectedCoin,
                    items: coins
                        .map(
                          (coin) => DropdownMenuItem(
                            value: coin,
                            child: Text(coin),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCoin = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Coin",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dropdown Menu for Buy/Sell
                  DropdownButtonFormField<String>(
                    value: selectedTradeType,
                    items: const [
                      DropdownMenuItem(
                        value: 'Buy',
                        child: Text('Buy'),
                      ),
                      DropdownMenuItem(
                        value: 'Sell',
                        child: Text('Sell'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedTradeType = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Trade Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Total Invested TextField
                  TextField(
                    controller: _investedController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => calculateTotal(),
                    decoration: const InputDecoration(
                      labelText: "Total Amount (\$)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price TextField
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => calculateTotal(),
                    decoration: const InputDecoration(
                      labelText: "Price per Coin (\$)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Total Amount Display
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Coins:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Text(
                          totalAmount.toStringAsFixed(2),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text("Cancel"),
        ),

        // Add Button
        isLoading2
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () async {
                  if (selectedCoin != null &&
                      _investedController.text.isNotEmpty &&
                      _priceController.text.isNotEmpty &&
                      selectedTradeType != null) {
                    // Handle the "Add" logic
                    setState(() {
                      isLoading2 = true;
                    });
                    if (await isSellValid(
                        selectedCoin, totalAmount, selectedTradeType)) {
                      addTrade();
                      final investment = _investedController.text.trim();
                      updateTotalInvestByCoinName(
                          selectedCoin,
                          double.parse(investment),
                          totalAmount,
                          selectedTradeType);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Insufficient coins to sell. Please check your holdings."),
                        ),
                      );
                      setState(() {
                        isLoading2 = false;
                      });
                    }

                    // Close the dialog after adding
                  } else {
                    // Show error if fields are not filled
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill in all the fields"),
                      ),
                    );
                  }
                },
                child: const Text("Add"),
              ),
      ],
    );
  }
}
