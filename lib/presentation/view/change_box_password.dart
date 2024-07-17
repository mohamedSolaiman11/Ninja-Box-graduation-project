import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database
import 'package:flutter/material.dart';

import '../../utils/app_color.dart';
import '../widgets/custom_pass_guard.dart';

class ChangeBoxPassword extends StatefulWidget {
  ChangeBoxPassword({super.key});

  @override
  State<ChangeBoxPassword> createState() => _ChangeBoxPasswordState();
}

class _ChangeBoxPasswordState extends State<ChangeBoxPassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final FocusNode oldPassFocusNode = FocusNode();
  final FocusNode newPassFocusNode = FocusNode();
  final FocusNode confirmNewPasswordFocusNode = FocusNode();
  bool _isLoading = false;
  dynamic _initialPassword;
  String? _errorMessage;

  // Reference to the password node in Realtime Database
  final databaseReference =
  FirebaseDatabase.instance.ref().child('password-of-box/password');

  @override
  void initState() {
    super.initState();
    _fetchBoxPassword(); // Fetch the initial password
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchBoxPassword() async {
    try {
      final snapshot = await databaseReference.get();
      if (snapshot.exists) {
        setState(() {
          _initialPassword = snapshot.value.toString();
          _oldPasswordController.text = _initialPassword!;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching password: $e';
      });
    }
  }

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });


    try {
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmNewPasswordController.text;
      if (!RegExp(r'^\d{4}$').hasMatch(newPassword)) {
        _showSnackBar('Password must be exactly 4 numbers.');
        _clearPasswordFields();
        return;
      }
      if (newPassword != confirmPassword) {
        _showSnackBar('New password and confirmation do not match.');
        _clearPasswordFields();
        return;
      }

      // Update the password in Realtime Database
      await databaseReference.set(newPassword);
      _showSnackBar('Password changed successfully!');
      _clearPasswordFields();
      _fetchBoxPassword(); // Re-fetch the updated password
    } catch (e) {
      _showSnackBar('Error changing password: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearPasswordFields() {
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
  }

  void _showSnackBar(String message) {
    if (message.contains("error") ||
        message.contains("incorrect") ||
        message.contains("do not")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColorGreen,
        title: const Text(
          "Change Box Password",
          style: TextStyle(fontSize: 22, color: AppColor.textSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Center(
            child: Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.only(top: screenSize.width * 0.05),
                height: screenSize.height * 0.8,
                padding: EdgeInsets.all(screenSize.width * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    SizedBox(height: screenSize.width * 0.05),
                    _buildLockIcon(screenSize),
                    SizedBox(height: screenSize.height * 0.05),
                    _buildPasswordFields(screenSize),
                    SizedBox(height: screenSize.height * 0.04),
                    _buildChangeButton(screenSize),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon(Size screenSize) => Container(
    margin: EdgeInsets.symmetric(horizontal: screenSize.width*.23),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: screenSize.width * 0.38,
        height: screenSize.width * 0.38,
        color: Colors.grey.shade300,
        child: Icon(
          Icons.lock,
          size: screenSize.width * 0.15,
          color: Colors.black,
        ),
      ),
    ),
  );

  Widget _buildPasswordFields(Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
      child: Column(
        children: [
          if (_errorMessage != null)
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          CustomPasswordTextField(
            focusNode: oldPassFocusNode,
            controller: _oldPasswordController,
            label: 'Old password',
            textWillAppearInNotVaildate: 'invalid password', maxLength: 4,
          ),
          SizedBox(height: screenSize.height * 0.025),
          CustomPasswordTextField(
            focusNode: newPassFocusNode,
            controller: _newPasswordController,
            label: 'New password',
            textWillAppearInNotVaildate: 'invalid password', maxLength: 4,
          ),
          SizedBox(height: screenSize.height * 0.025),
          CustomPasswordTextField(

            focusNode: confirmNewPasswordFocusNode,
            controller: _confirmNewPasswordController,
            label: 'Confirm new password',
            textWillAppearInNotVaildate: 'invalid password', maxLength: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(Size screenSize) => _isLoading
      ? CircularProgressIndicator(
    valueColor:
    AlwaysStoppedAnimation<Color>(AppColor.primaryColorGreen),
  )
      : ElevatedButton(
    onPressed: _changePassword,
    child: const Text("Change ",
        style: TextStyle(fontSize: 22, color: Colors.white)),
    style: ButtonStyle(
      padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.31,
              vertical: screenSize.height * 0.02)),
      backgroundColor:
      MaterialStateProperty.all(AppColor.primaryColorGreen),
    ),
  );
}

