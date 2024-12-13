import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkColor,
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
                'lib/assets/images/screen2.png',
                width: screenWidth * 0.8,
                height: screenHeight * 0.3,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              // Title Text with responsive font size
              Text(
                '"Manage And Track"',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: screenWidth * 0.07, // Dynamic font size
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              // Description Text with responsive font size
              Text(
                "Efficiently manage and track all your cryptocurrency trades in one place. Our platform offers an intuitive interface to help you stay organized, monitor your performance, and analyze trends for smarter trading decisions.",
                style: TextStyle(
                  color: AppTheme.primaryColor,
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
