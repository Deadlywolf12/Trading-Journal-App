import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/pages/add_fav_coin.dart';
import 'package:tj/components/server/functions/api_get_coins.dart';

class CryptoMarket extends StatefulWidget {
  @override
  _CryptoMarketState createState() => _CryptoMarketState();
}

class _CryptoMarketState extends State<CryptoMarket> {
  Future<Map<String, dynamic>>? cryptoPrices;
  final Set<String> selectedCoins = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteCoins();
  }

  Future<void> _loadFavoriteCoins() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() {
        cryptoPrices = Future.error('User not logged in');
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fav_coins')
          .get();

      for (var doc in snapshot.docs) {
        final coinName = doc.data()['coin'];
        selectedCoins.add(coinName.toLowerCase());
      }

      setState(() {
        cryptoPrices = fetchCryptoPrices(selectedCoins.toList());
      });
    } catch (e) {
      setState(() {
        cryptoPrices = Future.error('Error loading favorite coins: $e');
      });
    }
  }

  void _navigateToAddCoinPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddCoinToFav()))
        .then((_) {
      _loadFavoriteCoins();
    });
  }

  Future<void> _deleteCoinFromFavorites(String coinName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fav_coins')
          .where('coin', isEqualTo: coinName)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$coinName removed from favorites')),
      );

      _loadFavoriteCoins();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting coin: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crypto Prices"),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.blackColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddCoinPage(context),
          ),
        ],
      ),
      body: cryptoPrices == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
              future: cryptoPrices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const AlertDialog(
                    title: Text("Error"),
                    content: Text(
                        "Error: Could'nt Fetch Data From Api, Please Check Your Internet Connection "),
                    backgroundColor: AppTheme.errorColor,
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const AlertDialog(
                    title: Text("Error"),
                    content: const Text(
                        "No data available. Add your favorite coins!"),
                    backgroundColor: AppTheme.errorColor,
                  );
                }

                final prices = snapshot.data!;
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final coinName = prices.keys.elementAt(index);
                    final data = prices[coinName];
                    final price = data['usd'];
                    final priceChange24h = data['usd_24h_change'];
                    final high24h = data['high_24h'];
                    final low24h = data['low_24h'];
                    final imageUrl = data['image']; // Get image URL

                    return Dismissible(
                      key: Key(coinName),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteCoinFromFavorites(coinName);
                      },
                      background: Container(
                        color: AppTheme.errorColor,
                        child: const Icon(
                          Icons.delete,
                          color: AppTheme.whiteColor,
                          size: 30,
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                      ),
                      child: Card(
                        elevation: 10,
                        margin: const EdgeInsets.only(bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.tilesColor,
                                AppTheme.tilesColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: imageUrl != null &&
                                        imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage(
                                            'https://th.bing.com/th/id/OIP.bzUJ68L-NIlySeNOL6Vc_wHaHa?rs=1&pid=ImgDetMain')
                                        as ImageProvider,
                                radius: 30,
                                backgroundColor: Colors.transparent,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      coinName.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.whiteColor,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "\$${price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    priceChange24h != null
                                        ? "${priceChange24h.toStringAsFixed(2)}%"
                                        : "N/A",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: priceChange24h != null &&
                                              priceChange24h >= 0
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "24h Change",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.disabledColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
