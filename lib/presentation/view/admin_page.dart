import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project2024/utils/app_color.dart';
import 'package:graduation_project2024/utils/app_images_path.dart';
import '../widgets/custom_email_guard.dart';
import '../widgets/custom_email_text_field.dart';
import '../widgets/custom_pass_guard.dart';
import '../widgets/go_to_page_only.dart';
import 'control_admin/control_admin_cubit.dart';
import 'home_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController emailLoginController = TextEditingController();
  final TextEditingController passwordLoginController = TextEditingController();
  final TextEditingController emailSignUpController = TextEditingController();
  final TextEditingController passwordSignUpController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final GlobalKey<FormState> _formKeyRegister = GlobalKey();
  final GlobalKey<FormState> _formKeyLogin = GlobalKey();
  bool _isLoading = false;
  bool isLoginSelected = true;

  FirebaseMessaging fbm = FirebaseMessaging.instance;
  User? user;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        this.user = user;
        if (user != null) {
          emailLoginController.text = user.email ?? '';
        }
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkSerialIDAndRegister() async {
    String enteredSerial = idController.text.trim();
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('serial_number_of_box')
          .doc('serialNumber')
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('serial') && data['serial'] == enteredSerial) {
          await _register();
        } else {
          _showSnackBar(context, "Serial number not found");
        }
      } else {
        _showSnackBar(context, "Serial number not found");
      }
    } catch (e) {
      _showSnackBar(context, "Error checking serial: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.textSecondaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderImage(size.width, size.height),
              _buildToggleText(context, size.width * .075),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: isLoginSelected ? _buildLoginForm(context, _formKeyLogin, emailLoginController, passwordLoginController) : _buildRegisterForm(context, _formKeyRegister, passwordSignUpController, rePasswordController, size.height * 0.02),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(double widthSize, double heightSize) {
    return Container(
      width: widthSize * .6,
      height: heightSize * .34,
      padding: EdgeInsets.only(top: heightSize * .03),
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.asset(AppImagesPath.box_image_path),
      ),
    );
  }

  Widget _buildToggleText(BuildContext context, double size) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          _buildRichTextSpan(
            context,
            'Register ',
            isLoginSelected ? Colors.black : Colors.orange,
                () {
              setState(() {
                isLoginSelected = false;
              });
              BlocProvider.of<ControlAdminCubit>(context).getRegisterPage();
            },
            size,
          ),
          const TextSpan(
            text: '|',
            style: TextStyle(fontSize: 25, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          _buildRichTextSpan(
            context,
            ' Login',
            isLoginSelected ? Colors.orange : Colors.black,
                () {
              setState(() {
                isLoginSelected = true;
              });
              BlocProvider.of<ControlAdminCubit>(context).getLoginPage();
            },
            size,
          ),
        ],
      ),
    );
  }
  TextSpan _buildRichTextSpan(BuildContext context, String text, Color color, VoidCallback onTap, double size) {
    return TextSpan(
      text: text,
      style: TextStyle(fontSize: size, color: color),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  Widget _buildRegisterForm(
      BuildContext context,
      GlobalKey<FormState> formKey,
      TextEditingController passwordController,
      TextEditingController rePasswordController,
      double size,
      ) {
    return _buildFormContainer(
      formKey,
      500,
      [
        SizedBox(height: size),
        _buildFormHeader("REGISTER"),
        SizedBox(height: size),
        CustomEmailTextField(
          controller: idController,
          label: 'Enter serial ID of your box',
          textInputType: TextInputType.number,
          textWillAppearInNotVaildate: 'Invalid ID',
        ),
        SizedBox(height: size),
        CustomEmailTextField(
          controller: emailSignUpController,
          label: 'Email',
          textInputType: TextInputType.emailAddress,
          textWillAppearInNotVaildate: 'Invalid email',
        ),
        SizedBox(height: size),
        CustomPasswordTextField(
          label: "Password",
          controller: passwordController,
          textWillAppearInNotVaildate: 'Invalid password',
          maxLength: 6,
        ),
        CustomPasswordTextField(
          label: "Re-enter Password",
          controller: rePasswordController,
          textWillAppearInNotVaildate: 'Invalid password',
          maxLength: 6,
        ),
        _isLoading ? CircularProgressIndicator() : _buildSubmitButton(context, "Sign Up", () async {
          if (formKey.currentState!.validate()) {
            setState(() => _isLoading = true);
            await _checkSerialIDAndRegister();
            setState(() => _isLoading = false);
          }
        }),
      ],
    );
  }

  Widget _buildLoginForm(
      BuildContext context,
      GlobalKey<FormState> formKey,
      TextEditingController emailController,
      TextEditingController passwordController,
      ) {
    return _buildFormContainer(
      formKey,
      360,
      [
        SizedBox(height: 20),
        _buildFormHeader("LOGIN"),
        SizedBox(height: 20),
        CustomEmailTextFieldGuard(
          controller: emailController,
          label: 'Email',
          textInputType: TextInputType.emailAddress,
          textWillAppearInNotVaildate: 'Invalid email',
        ),
        SizedBox(height: 20),
        CustomPasswordTextField(
          label: "Password",
          controller: passwordController,
          textWillAppearInNotVaildate: 'Invalid password',
          maxLength: 6,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                _showForgotPasswordDialog(context);
              },
              child: Text(
                "Forgot password?",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        _isLoading ? CircularProgressIndicator() : _buildSubmitButton(context, "Log in", () async {
          if (formKey.currentState!.validate()) {
            setState(() => _isLoading = true);
            await _login();
            setState(() => _isLoading = false);
          }
        }),
      ],
    );
  }

  Widget _buildFormContainer(GlobalKey<FormState> formKey, double height, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.green,
            blurRadius: 1,
            spreadRadius: 1,
            blurStyle: BlurStyle.outer,
          ),
        ],
        color: Colors.white.withOpacity(.3),
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildFormHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        letterSpacing: 3,
        color: AppColor.textPrimaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        ),
        backgroundColor: MaterialStateProperty.all(AppColor.yellow),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKeyRegister.currentState!.validate()) return;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showSnackBar(context, "Check your internet connection");
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailSignUpController.text.trim(),
        password: passwordSignUpController.text.trim(),
      );
      clearTextField();
      _showSnackBar(context, "Account created successfully");
    }
    on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _showSnackBar(context, "The email address is already in use by another account.");
          break;
        case 'invalid-email':
          _showSnackBar(context, "The email address is not valid.");
          break;
        case 'operation-not-allowed':
          _showSnackBar(context, "Email/password accounts are not enabled.");
          break;
        case 'weak-password':
          _showSnackBar(context, "The password is too weak.");
          break;
        default:
          _showSnackBar(context, "An error occurred. Please try again.");
          break;
      }
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }

  Future<void> _login() async {
    if (!_formKeyLogin.currentState!.validate()) return;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showSnackBar(context, "Check your internet connection");
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailLoginController.text.trim(),
        password: passwordLoginController.text.trim(),
      );

      _showSnackBar(context, "Login successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.message) {
        case 'user-not-found':
          _showSnackBar(context, "This email not found");
          break;
        case 'The supplied auth credential is incorrect, malformed or has expired.':
          _showSnackBar(context, "Wrong password");
          break;
        case 'invalid-credential':
          _showSnackBar(context, "The supplied auth credential is incorrect, malformed, or has expired.");
          break;
        case 'too-many-requests':
          _showSnackBar(context, "too-many-requests");
          break;
        default:
          _showSnackBar(context, "An error occurred. Please try again.");
          break;
      }
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController forgotPasswordController = TextEditingController();
        return AlertDialog(
          title: Text("Forgot Password"),
          content: TextField(
            controller: forgotPasswordController,
            decoration: InputDecoration(hintText: "Enter your email"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Send"),
              onPressed: () async {
                if (forgotPasswordController.text.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: forgotPasswordController.text.trim());
                    _showSnackBar(context, "Password reset email sent");
                    Navigator.of(context).pop();
                  } catch (e) {
                    _showSnackBar(context, e.toString());
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }

  void clearTextField() {
    idController.clear();
    emailSignUpController.clear();
    passwordSignUpController.clear();
    rePasswordController.clear();
  }
}
