import 'package:flutter/material.dart';

class CustomEmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType textInputType;
  final String textWillAppearInNotVaildate;
  final FocusNode? focusNode;
  final IconData prefixIcon;

  const CustomEmailTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.textInputType,
    required this.textWillAppearInNotVaildate,
    this.focusNode,
    this.prefixIcon =  Icons.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: textInputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: !label.contains("Enter serial ID")? Icon(prefixIcon):Icon(Icons.numbers),
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
