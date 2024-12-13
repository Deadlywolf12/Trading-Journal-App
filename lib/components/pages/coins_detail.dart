import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/widgets/trade_dialoge.dart';
import 'package:tj/components/widgets/trade_tile.dart';

class CoinDetailsPage extends StatelessWidget {
  final String coinName;
  final String cost;
  final String investment;
  final String profit;
  final String totalCoins;
  final formatter = NumberFormat.compact();
  final currencyFormatter =
      NumberFormat.currency(symbol: "\$", decimalDigits: 3);

  CoinDetailsPage({
    Key? key,
    required this.coinName,
    required this.cost,
    required this.investment,
    required this.profit,
    required this.totalCoins,
  }) : super(key: key);

  void _openEditTradeDialog(BuildContext context, String tradeId) {
    showDialog(
      context: context,
      builder: (context) => EditTradeDialog(tradeId: tradeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double parsedProfit = double.tryParse(profit) ?? 0.0;
    final double parsedTotalCoins = double.tryParse(totalCoins) ?? 0.0;
    final double avgCost = double.tryParse(cost) ?? 0.0;
    final double invest = double.tryParse(investment) ?? 0.0;

    String formattedTotalCoins = parsedTotalCoins.toStringAsFixed(4);
    return Scaffold(
      body: Column(
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: AppTheme.blackColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    coinName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blackColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Avg Cost: ${currencyFormatter.format(avgCost)}",
                            style: const TextStyle(color: AppTheme.blackColor),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Investment: ${currencyFormatter.format(invest)}",
                            style: const TextStyle(color: AppTheme.blackColor),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Profit: ${currencyFormatter.format(parsedProfit)}",
                            style: TextStyle(
                              color: (double.tryParse(profit) ?? 0) > 0
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Total Coins: ${formattedTotalCoins}",
                            style: const TextStyle(color: AppTheme.blackColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TradesList(
              coinName: coinName,
              onEditTrade: (tradeId) {
                _openEditTradeDialog(context, tradeId);
              },
            ),
          ),
        ],
      ),
    );
  }
}
