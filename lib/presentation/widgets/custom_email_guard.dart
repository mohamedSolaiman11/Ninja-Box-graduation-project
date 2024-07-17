// CustomEmailTextField.dart
import 'package:flutter/material.dart';

class CustomEmailTextFieldGuard extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType textInputType;
  final String textWillAppearInNotVaildate;
  final FocusNode? focusNode;

  const CustomEmailTextFieldGuard({
    required this.controller,
    required this.label,
    required this.textInputType,
    required this.textWillAppearInNotVaildate,
     this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: textInputType,
      decoration: InputDecoration(labelText: label,
        prefixIcon: label.contains("id")?Icon(Icons.numbers): Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return textWillAppearInNotVaildate;
        }
        return null;
      },
    );
  }
}
