import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project2024/presentation/widgets/custom_email_guard.dart';
import 'package:graduation_project2024/presentation/widgets/custom_pass_guard.dart';
import '../../utils/app_color.dart';
import 'home_page_for_guard.dart';

class GuardPage extends StatefulWidget {
  const GuardPage({Key? key}) : super(key: key);

  @override
  State<GuardPage> createState() => _GuardPageState();
}

class _GuardPageState extends State<GuardPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: screenSize.width * 0.9,
            child: Column(
              children: [
                SizedBox(height: screenSize.height * 0.15),
                _buildZenaBoxImage(screenSize),
                SizedBox(height: screenSize.height * 0.03),
                _buildLoginForm(context, screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZenaBoxImage(Size screenSize) => Image.asset(
    "assets/images/branding1.png",
    width: screenSize.width * 0.8,
    height: screenSize.height * 0.3,
  );

  Widget _buildLoginForm(BuildContext context, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.green,
            blurRadius: 1,
            spreadRadius: 1,
            blurStyle: BlurStyle.outer,
          ),
        ],
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "LOGIN",
              style: TextStyle(
                letterSpacing: 3,
                color: AppColor.btnGreenColor,
                fontSize: screenSize.width * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            CustomEmailTextFieldGuard(
              controller: _emailController,
              label: 'Email',
              textInputType: TextInputType.emailAddress,
              textWillAppearInNotVaildate: 'Invalid email',
              focusNode: _emailFocusNode,
            ),
            SizedBox(height: screenSize.height * 0.03),
            CustomPasswordTextField(
              label: "Password",
              focusNode: _passwordFocusNode,
              controller: _passwordController,
              textWillAppearInNotVaildate: 'Invalid password',
              maxLength: 6,
            ),
            SizedBox(height: screenSize.height * 0.03),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => _signIn(context),
              child: const Text("Log in", style: TextStyle(fontSize: 20, color: Colors.white)),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.12,
                    vertical: screenSize.height * 0.015,
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(AppColor.primaryColorGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showSnackBar(context, "Check your internet connection");
      return;
    }

    if (connectivityResult == ConnectivityResult.mobile) {
      final notHasInternet = await _hasInternetConnection();
      if (!notHasInternet) {
        _showSnackBar(context, "No internet connection");
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot guardSnapshot = await FirebaseFirestore.instance.collection('guard').get();
      bool userFound = false;

      for (var doc in guardSnapshot.docs) {
        if (doc['email'] == _emailController.text && doc['password'] == _passwordController.text) {
          userFound = true;
          _emailController.text = "";
          _passwordController.text = "";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePageForGuard()),
          );
          break;
        }
      }

      if (!userFound) {
        _showSnackBar(context, 'Invalid email or password');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
