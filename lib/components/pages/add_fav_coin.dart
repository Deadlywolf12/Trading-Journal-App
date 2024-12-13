import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/server/functions/api_get_coins.dart';

class AddCoinToFav extends StatefulWidget {
  @override
  _AddCoinToFavState createState() => _AddCoinToFavState();
}

class _AddCoinToFavState extends State<AddCoinToFav> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> topCoins = [];
  String selectedCoinId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllCoins().then((coins) {
      setState(() {
        topCoins = coins;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Coin to Favorites'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            topCoins.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _controller, // Attach the controller
                      decoration: InputDecoration(
                        labelText: 'Search for a coin',
                        labelStyle: const TextStyle(
                          color: AppTheme.blackColor,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: AppTheme.infoColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: AppTheme.successColor,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.whiteColor,
                        ),
                        filled: true,
                        fillColor: AppTheme.primaryColor,
                        contentPadding: const EdgeInsets.all(15),
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return topCoins.where((coin) => coin['name']!
                          .toLowerCase()
                          .contains(pattern.toLowerCase()));
                    },
                    itemBuilder: (context, Map<String, String> suggestion) {
                      return ListTile(
                        title: Text(suggestion['name']!),
                      );
                    },
                    onSuggestionSelected: (Map<String, String> suggestion) {
                      setState(() {
                        selectedCoinId = suggestion['id']!;
                      });
                      _controller.text =
                          suggestion['name']!; // Update the field
                    },
                  ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  )
                : ElevatedButton(
                    onPressed: selectedCoinId.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _isLoading = true;
                            });
                            _addCoinToFavorites(selectedCoinId);
                          },
                    child: const Text('Add Coin'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCoinToFavorites(String coinId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fav_coins')
          .add({'coin': coinId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$coinId added to favorites')),
      );
      _isLoading = false;

      Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding coin: $e')),
      );
      _isLoading = false;
    }
  }
}
