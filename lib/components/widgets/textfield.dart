import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppTextField extends StatelessWidget {
  AppTextField(
      {super.key,
      required this.label,
      required this.icon,
      required this.inputType,
      this.isObscure = false,
      required this.controller});
  final String label;
  Icon icon;
  TextInputType inputType;
  bool isObscure;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: icon,
      ),
      keyboardType: inputType,
      obscureText: isObscure,
      controller: controller,
    );
  }
}
