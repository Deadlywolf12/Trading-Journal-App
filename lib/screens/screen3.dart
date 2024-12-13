import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';

class IntroScreen3 extends StatelessWidget {
  const IntroScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image with responsive width and height
              Image.asset(
                'lib/assets/images/screen3.png',
                width: screenWidth * 0.8,
                height: screenHeight * 0.3,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              // Title Text with responsive font size
              Text(
                '"Live Market Updates"',
                style: TextStyle(
                  color: AppTheme.backgroundDarkColor,
                  fontSize: screenWidth * 0.07, // Dynamic font size
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              // Description Text with responsive font size
              Text(
                "et real-time cryptocurrency price updates, market trends, and fluctuations. Stay informed with accurate data to make timely trading decisions and track the latest market changes.",
                style: TextStyle(
                  color: AppTheme.backgroundDarkColor,
                  fontSize: screenWidth * 0.045, // Dynamic font size
                  height: 1.5, // Line height for better readability
                  fontFamily: 'Arial',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
