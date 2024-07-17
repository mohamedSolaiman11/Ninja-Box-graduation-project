import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../widgets/custom_email_guard.dart';
import '../widgets/custom_pass_guard.dart';

class AddGuard extends StatefulWidget {
  const AddGuard({Key? key}) : super(key: key);

  @override
  _AddGuardState createState() => _AddGuardState();
}

class _AddGuardState extends State<AddGuard> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  List<Map<String, String>> guards = [];
  String? selectedGuardEmail;

  @override
  void dispose() {
    emailController.dispose();
    idController.dispose();
    passwordController.dispose();
    _emailFocusNode.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchGuards();
  }

  Future<void> fetchGuards() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('guard').get();
      List<Map<String, String>> tempGuards = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        tempGuards.add({'email': data['email'], 'password': data['password']});
      }

      setState(() {
        guards = tempGuards;
      });
    } catch (e) {
      print("Error fetching guards: $e");
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
          "Add Guard",
          style: TextStyle(fontSize: 26, color: AppColor.textSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding:  EdgeInsets.symmetric(horizontal: screenSize.width*.05,vertical: screenSize.height*0.02),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    guards.isEmpty
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Guard Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      value: selectedGuardEmail,
                      items: guards.map((guard) {
                        return DropdownMenuItem<String>(
                          value: guard['email'],
                          child: Text(guard['email']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGuardEmail = value;
                        });
                      },
                      isExpanded: true,
                    ),
                    selectedGuardEmail == null
                        ? Container()
                        : Card(
                      color: Colors.lightBlue.shade50,
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Selected Guard Password: ${guards.firstWhere((guard) => guard['email'] == selectedGuardEmail)['password']}',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                     SizedBox(height: screenSize.height*0.03),
                    _buildProfileImage(widthSize: screenSize.width*.4,heightSize: screenSize.width*.4),
                     SizedBox(height: screenSize.height*0.03),
                    CustomEmailTextFieldGuard(
                      controller: emailController,
                      label: 'Enter guard email',
                      textInputType: TextInputType.emailAddress,
                      textWillAppearInNotVaildate: 'Invalid email',
                      focusNode: _emailFocusNode,
                    ),
                     SizedBox(height: screenSize.height*0.02),
                    CustomEmailTextFieldGuard(
                      controller: idController,
                      label: 'Enter guard id',
                      textInputType: TextInputType.number,
                      textWillAppearInNotVaildate: 'Invalid number',
                      focusNode: _idFocusNode,
                    ),
                    SizedBox(height: screenSize.height*0.02),
                    CustomPasswordTextField(
                      focusNode: _passwordFocusNode,
                      controller: passwordController,
                      label: 'Enter guard password',
                      textWillAppearInNotVaildate: 'Invalid password',
                      maxLength: 6,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : _buildAddButton(context,screenSize.height*.075,screenSize.width*.92),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage({required double widthSize,required double heightSize}) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(100)),
      child: Container(
        width: widthSize,
        height: widthSize,
        color: Colors.grey.shade300,
        child: Image.asset(
          "assets/icons/imageSecurity.jpeg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context,double heightSize,double widthSize) {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });
          await _registerGuard(
            context,
            idController.text.trim(),
            emailController.text.trim(),
            passwordController.text.trim(),
          );
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Container(
        width: widthSize,
        height: heightSize,
        decoration: BoxDecoration(
          color: AppColor.primaryColorGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Add",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }

  Future<void> _registerGuard(BuildContext context, String guardId, String email, String password) async {
    try {
      // Check if ID already exists
      DocumentSnapshot idSnapshot = await FirebaseFirestore.instance.collection('guard').doc(guardId).get();
      if (idSnapshot.exists) {
        _showSnackBar(context, 'ID is already taken.', isError: true);
        return;
      }

      // Check if email already exists
      QuerySnapshot emailSnapshot = await FirebaseFirestore.instance.collection('guard').where('email', isEqualTo: email).get();
      if (emailSnapshot.docs.isNotEmpty) {
        _showSnackBar(context, 'Email is already taken.', isError: true);
        return;
      }

      // Add new guard
      await FirebaseFirestore.instance.collection('guard').doc(guardId).set({
        'email': email,
        'password': password,
      });

      _showSnackBar(context, 'Guard added successfully');
      _clearTextFields();
    } catch (e) {
      _showSnackBar(context, 'Error adding guard details: $e', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _clearTextFields() {
    emailController.clear();
    idController.clear();
    passwordController.clear();
  }
}
