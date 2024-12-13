import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tj/auth_page.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/screens/screen1.dart';
import 'package:tj/screens/screen2.dart';
import 'package:tj/screens/screen3.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool _isLastPage = false;
  bool _isSecPage = false;

  PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (value) {
            setState(() {
              _isLastPage = (value == 2);
              _isSecPage = (value == 1);
            });
          },
          children: [
            const IntroScreen1(),
            const IntroScreen2(),
            const IntroScreen3(),
          ],
        ),
        Container(
            alignment: const Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _isLastPage
                    ? GestureDetector(
                        child: const Text(
                          "Back",
                          style: TextStyle(
                              color: AppTheme.blackColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _controller.previousPage(
                            duration: const Duration(microseconds: 500),
                            curve: Curves.easeIn),
                      )
                    : GestureDetector(
                        child: Text(
                          "Skip",
                          style: TextStyle(
                              color: _isSecPage
                                  ? AppTheme.primaryColor
                                  : AppTheme.blackColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _controller.jumpToPage(3),
                      ),
                SmoothPageIndicator(controller: _controller, count: 3),
                _isLastPage
                    ? GestureDetector(
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: AppTheme.blackColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage())))
                    : GestureDetector(
                        child: Text(
                          "Next",
                          style: TextStyle(
                              color: _isSecPage
                                  ? AppTheme.primaryColor
                                  : AppTheme.blackColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn),
                      ),
              ],
            )),
      ],
    ));
  }
}
