import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/widgets/dialogue.dart';

import 'package:tj/components/widgets/textfield.dart';

class SignupPage extends StatefulWidget {
  final Function()? onTap;
  SignupPage({super.key, required this.onTap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  final _password2Controller = TextEditingController();
  bool _isloading = false;

  void signup() async {
    String p1 = _passwordController.text.trim();
    String p2 = _password2Controller.text.trim();

    if (p1 == p2) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(credential.user!.uid)
            .set({
          'email': _usernameController.text.trim(),
          'invested': 0,
          'remaining': 0,
          'profit': 0,
          'loss': 0,
          'usdToInvest': 0,
        });
        setState(() {
          _isloading = false;
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showErrorDialog(
              context, "The password provided is too weak. must be atleast 6");
          setState(() {
            _isloading = false;
          });
        } else if (e.code == 'email-already-in-use') {
          showErrorDialog(
              context, "The account already exists for that email.");
          setState(() {
            _isloading = false;
          });
        }
      } catch (e) {
        print("Error: $e");
        showErrorDialog(context, "An unexpected error occurred: $e");
        setState(() {
          _isloading = false;
        });
      }
    } else {
      showErrorDialog(context, "Passwords Doesn't Match");
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Name
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: size.width * 0.08, // Adjust font size dynamically
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: size.height * 0.05), // Add some vertical space

              // Email Field
              AppTextField(
                label: "Email",
                icon: const Icon(Icons.email),
                inputType: TextInputType.emailAddress,
                controller: _usernameController,
              ),

              SizedBox(height: size.height * 0.02),

              // Password Field
              AppTextField(
                label: "Password",
                icon: const Icon(Icons.lock),
                inputType: TextInputType.visiblePassword,
                isObscure: true,
                controller: _passwordController,
              ),
              SizedBox(height: size.height * 0.02),

              // Password Field
              AppTextField(
                label: "Confirm Password",
                icon: const Icon(Icons.lock),
                inputType: TextInputType.visiblePassword,
                isObscure: true,
                controller: _password2Controller,
              ),
              SizedBox(height: size.height * 0.04),
              GestureDetector(
                onTap: widget.onTap,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    "Already a user? SignIn",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // Login Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isloading = true;
                  });
                  if (_usernameController.text.isNotEmpty &&
                      _password2Controller.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    signup();
                  } else {
                    setState(() {
                      _isloading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please Fill All Fields"),
                      ),
                    );
                  }
                },
                child: Container(
                  width: size.width * 0.9,
                  height: size.height * 0.06,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset:
                            const Offset(0, 4), // changes position of shadow
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isloading
                      ? const CircularProgressIndicator(
                          color: AppTheme.blackColor,
                        )
                      : Text(
                          "Signup",
                          style: TextStyle(
                            color: AppTheme.blackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }
}
