import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/pages/market_page.dart';
import 'package:tj/components/pages/dashboard.dart';
import 'package:tj/components/pages/portfoliopage.dart';
import 'package:tj/components/pages/settingspage.dart';

class NavigationBarExample extends StatefulWidget {
  @override
  _NavigationBarExampleState createState() => _NavigationBarExampleState();
}

class _NavigationBarExampleState extends State<NavigationBarExample> {
  int _currentIndex = 0;

  // List of pages to display for each navigation bar item
  final List<Widget> _pages = [
    DashboardPage(),
    const PortfolioPage(),
    CryptoMarket(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_sharp),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: AppTheme.primaryColor, // Active item color
        unselectedItemColor: Colors.grey, // Inactive item color
        showUnselectedLabels: true, // Show labels for unselected items
      ),
    );
  }
}
