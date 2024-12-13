import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tj/auth_page.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/pages/on_boarding_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            scaffoldBackgroundColor: AppTheme.backgroundDarkColor,

            //0xFFEDF4F2
            //0xFF31473A
            useMaterial3: true,
            brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
          future: checkIfFirstTime(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                color: AppTheme.primaryColor,
              );
            }

            if (snapshot.data == true) {
              // First time, show intro screen if not web
              if (kIsWeb) {
                return AuthPage(); // Directly show main screen on web
              } else {
                return OnBoardingScreen(); // Show onboarding on mobile apps
              }
            } else {
              // User has already seen intro, show main screen
              return AuthPage();
            }
          },
        ));
  }

  Future<bool> checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');
    if (isFirstTime == null || isFirstTime) {
      // If first time, return true
      await prefs.setBool(
          'isFirstTime', false); // Mark that intro screen has been shown
      return true;
    } else {
      return false; // User has seen the intro screen before
    }
  }
}
