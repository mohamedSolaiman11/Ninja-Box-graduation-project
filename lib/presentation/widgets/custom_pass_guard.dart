import 'package:flutter/material.dart';

class CustomPasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String textWillAppearInNotVaildate;
  final FocusNode? focusNode;
  final int maxLength;

  const CustomPasswordTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.textWillAppearInNotVaildate,
    this.focusNode, required this.maxLength,
  }) : super(key: key);

  @override
  _CustomPasswordTextFieldGuardState createState() => _CustomPasswordTextFieldGuardState();
}

class _CustomPasswordTextFieldGuardState extends State<CustomPasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: widget.maxLength,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.textWillAppearInNotVaildate;
        }
        return null;
      },
    );
  }
}
