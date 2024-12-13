// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isButtonDisabled = false; // To disable the button during cooldown
  int _timerCountdown = 0; // Countdown timer in seconds
  Timer? _timer;

  // Function to start the timer
  void _startTimer() {
    const cooldownDuration = 30; // Cooldown in seconds
    setState(() {
      _isButtonDisabled = true;
      _timerCountdown = cooldownDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCountdown > 0) {
          _timerCountdown--;
        } else {
          _isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  // Function to send password reset email
  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Please enter your email.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackBar("Password reset email sent! Check your inbox.");
      _startTimer();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "invalid-email":
          errorMessage = "The email address is not valid.";
          break;
        case "user-not-found":
          errorMessage = "No user found with this email.";
          break;
        default:
          errorMessage = "An error occurred. Please try again.";
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("An unexpected error occurred.");
    }
  }

  // Function to show a SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel(); // Cancel the timer if active
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.blackColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter your email to receive a password reset link.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isButtonDisabled ? Colors.grey : AppTheme.primaryColor,
              ),
              child: Text(
                _isButtonDisabled
                    ? "Wait ${_timerCountdown}s"
                    : "Send Reset Email",
                style: TextStyle(color: AppTheme.blackColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
