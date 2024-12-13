import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tj/components/Configurations/theme.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double totalInvested = 0.0;
  double totalProfit = 0.0;
  double totalLoss = 0.0;
  double remaining = 0.0;
  double totalUsdToInvest = 0.0;
  bool _isLoading = true;
  final formatter = NumberFormat.compact();
  final currencyFormatter =
      NumberFormat.currency(symbol: "\$", decimalDigits: 2);

  List<Map<String, dynamic>> topGainers = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    fetchTopGainers();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          setState(() {
            totalInvested = data?['invested']?.toDouble() ?? 0.0;
            totalProfit = data?['profit']?.toDouble() ?? 0.0;
            totalLoss = data?['loss']?.toDouble() ?? 0.0;
            totalUsdToInvest = data?['usdToInvest']?.toDouble() ?? 0.0;
            remaining = totalUsdToInvest - totalInvested + totalProfit;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchTopGainers() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Sort by percentage gain in descending order
        data.sort((a, b) => (b['price_change_percentage_24h'] ?? 0.0)
            .compareTo(a['price_change_percentage_24h'] ?? 0.0));

        // Select top 5 gainers
        setState(() {
          topGainers = data.take(5).map((coin) {
            return {
              'name': coin['name'],
              'symbol': coin['symbol'],
              'price': coin['current_price'],
              'change': coin['price_change_percentage_24h'],
              'image': coin['image'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load top gainers');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching top gainers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text("Portfolio Dashboard"),
              centerTitle: true,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.blackColor,
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStatsSection(size),
                    const SizedBox(height: 20),
                    _buildGainersSection(),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildStatsSection(Size size) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: size.height * 0.4,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.tilesColor,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackColor,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.attach_money_sharp,
                  size: 40,
                  color: AppTheme.whiteColor,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Total Invested",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.whiteColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${currencyFormatter.format(totalInvested).toString()}",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.whiteColor,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    icon: Icons.monetization_on,
                    title: "Remaining",
                    value: "${currencyFormatter.format(remaining).toString()}",
                  ),
                  _buildStatColumn(
                    icon: Icons.moving_outlined,
                    title: "Total Profit",
                    value:
                        "${currencyFormatter.format(totalProfit).toString()}",
                  ),
                  _buildStatColumn(
                    icon: Icons.trending_down_outlined,
                    title: "Total Loss",
                    value: "${currencyFormatter.format(totalLoss).toString()}",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGainersSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Top Gainers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topGainers.length,
            itemBuilder: (context, index) {
              final coin = topGainers[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: Image.network(coin['image'], width: 40, height: 40),
                  title: Text(coin['name']),
                  subtitle: Text(
                    "Change: ${coin['change'].toStringAsFixed(2)}%",
                  ),
                  trailing: Text(
                    "\$${coin['price'].toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: AppTheme.whiteColor),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.whiteColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteColor),
        ),
      ],
    );
  }
}
