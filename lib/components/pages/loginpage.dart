import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tj/components/Configurations/theme.dart';
import 'package:tj/components/pages/forgot_pass.dart';
import 'package:tj/components/widgets/dialogue.dart';
import 'package:tj/components/widgets/textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim());
      setState(() {
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showErrorDialog(context, "no user found");
        setState(() {
          _isLoading = false;
        });
      } else if (e.code == 'invalid-credential') {
        showErrorDialog(context, "wrong password provided for that user.");
        setState(() {
          _isLoading = false;
        });
      } else {
        showErrorDialog(context, "An unexpected error occurred: ${e.message}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // For any other errors
      showErrorDialog(context, "An unknown error occurred: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "your",
                style: TextStyle(
                  fontSize: size.width * 0.09,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                "Trading journal...",
                style: TextStyle(
                  fontSize: size.width * 0.09,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: size.height * 0.05),

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
              GestureDetector(
                onTap: widget.onTap,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    "New to the app? Sign Up",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      // Adds an underline to indicate interactivity
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),

              // Login Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLoading = true;
                  });

                  if (_usernameController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    signIn();
                  } else {
                    setState(() {
                      _isLoading = false;
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
                        color: AppTheme.blackColor.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppTheme.blackColor,
                        )
                      : Text(
                          "Login",
                          style: TextStyle(
                            color: AppTheme.blackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    "Forgot your Password?",
                    style: TextStyle(
                      color: AppTheme.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      // Adds an underline to indicate interactivity
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
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
    super.dispose();
  }
}
