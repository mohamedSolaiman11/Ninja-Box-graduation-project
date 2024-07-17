import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../widgets/custom_pass_guard.dart';

class ChangeAccountPassword extends StatefulWidget {
  const ChangeAccountPassword({super.key});

  @override
  _ChangeAccountPasswordState createState() => _ChangeAccountPasswordState();
}

class _ChangeAccountPasswordState extends State<ChangeAccountPassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final FocusNode oldPassFocusNode = FocusNode();
  final FocusNode newPassFocusNode = FocusNode();
  final FocusNode confirmNewPasswordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _showSnackBar('No user is currently signed in.');
          return;
        }

        // Check if passwords match before authentication
        if (_newPasswordController.text != _confirmNewPasswordController.text) {
          _showSnackBar('New password and confirmation do not match.');
          setState(() => _isLoading = false); // Hide loading indicator since we won't proceed
          return;
        }

        // Reauthenticate with the old password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );
        try {
          await user.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            _showSnackBar('The old password you entered is incorrect.');
            setState(() => _isLoading = false);
            return; // Stop the process if the old password is wrong
          } else {
            // Handle other authentication errors if needed
            _showSnackBar('Error during reauthentication: ${e.message}');
            return;
          }
        }

        // Update password (only if reauthentication succeeds)
        await user.updatePassword(_newPasswordController.text);
        _showSnackBar('Password changed successfully!');
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
        // Add other Firebase Authentication error codes here as needed
          default:
            _showSnackBar('Error changing password: ${e.message}');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
        _clearPasswordFields();
      }
    }
  }

  void _clearPasswordFields() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.width < screenSize.height;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColorGreen,
        title: Text(
          "Change Account Password",
          style: TextStyle(
            fontSize: screenSize.width * 0.06, // Responsive font size
            color: AppColor.textSecondaryColor,
          ),
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
                padding: EdgeInsets.all(screenSize.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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

  Widget _buildLockIcon(Size screenSize) => ClipRRect(
    borderRadius: BorderRadius.circular(100),
    child: Container(
      width: screenSize.width * 0.3,
      height: screenSize.width * 0.3,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.lock,
        size: screenSize.width * 0.25,
        color: Colors.black,
      ),
    ),
  );

  Widget _buildPasswordFields(Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      child: Column(
        children: [
          CustomPasswordTextField(
            focusNode: oldPassFocusNode,
            controller: _oldPasswordController,
            label: 'Old Password',
            textWillAppearInNotVaildate: 'Invalid Password',
            maxLength: 6,
          ),
          SizedBox(height: screenSize.height * 0.025),
          CustomPasswordTextField(
            focusNode: newPassFocusNode,
            controller: _newPasswordController,
            label: 'New Password',
            textWillAppearInNotVaildate: 'Invalid Password',
            maxLength: 6,
          ),
          SizedBox(height: screenSize.height * 0.025),
          CustomPasswordTextField(
            focusNode: confirmNewPasswordFocusNode,
            controller: _confirmNewPasswordController,
            label: 'Confirm New Password',
            textWillAppearInNotVaildate: 'Invalid Password',
            maxLength: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(Size screenSize) => _isLoading
      ? CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColorGreen),
  )
      : ElevatedButton(
    onPressed: _changePassword,
    child: Text(
      "Change",
      style: TextStyle(
        fontSize: screenSize.width * 0.05, // Responsive font size
        color: Colors.white,
      ),
    ),
    style: ButtonStyle(
      padding: MaterialStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.3,
          vertical: screenSize.height * 0.015,
        ),
      ),
      backgroundColor: MaterialStateProperty.all(AppColor.primaryColorGreen),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the button
      )),
    ),
  );

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains("error") ||
            message.contains("incorrect") ||
            message.contains("do not")
            ? Colors.red
            : Colors.green,
      ),
    );
  }
}
