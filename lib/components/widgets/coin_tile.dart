import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tj/components/Configurations/theme.dart';

class CoinTile extends StatelessWidget {
  final String title;
  final String cost;
  final String investment;
  final String profit; // Pass as String
  final String totalCoins; // Pass as String
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete; // Callback for delete icon
  final VoidCallback onReset; // Callback for reset icon

  final formatter = NumberFormat.compact();
  final currencyFormatter =
      NumberFormat.currency(symbol: "\$", decimalDigits: 4);

  CoinTile({
    Key? key,
    required this.title,
    required this.cost,
    required this.investment,
    required this.profit, // Pass profit
    required this.totalCoins, // Pass totalCoins
    required this.icon,
    required this.onTap,
    required this.onDelete, // Pass delete callback
    required this.onReset, // Pass reset callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely parse profit and totalCoins to doubles for formatting
    final double parsedProfit = double.tryParse(profit) ?? 0.0;
    final double parsedTotalCoins = double.tryParse(totalCoins) ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.tilesColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.tilesColor.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4), // Shadow position
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.whiteColor,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.whiteColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        cost,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.disabledColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        investment,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.disabledColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Profit: ${currencyFormatter.format(parsedProfit)}",
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.successColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Total Coins: ${parsedTotalCoins.toStringAsFixed(4)}", // Display total coins as plain double
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.disabledColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Delete icon at the top-right corner
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete, // Trigger the delete callback
                child: const Icon(Icons.delete,
                    size: 20, color: AppTheme.errorColor),
              ),
            ),
            // Reset icon at the bottom-right corner
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onReset, // Trigger the reset callback
                child: const Icon(Icons.refresh,
                    size: 20, color: AppTheme.infoColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
