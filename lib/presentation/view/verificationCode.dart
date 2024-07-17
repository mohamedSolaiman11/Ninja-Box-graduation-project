import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Verification extends StatefulWidget {
  const Verification({Key? key, this.initialCode}) : super(key: key);
  final String? initialCode; // To receive code from notification

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {

  String? _code;
  String? _timeOfLastCode;
  String? _vrCode;

  final databaseReference = FirebaseDatabase.instance.ref().child('verification-code');
  final TextEditingController _otpController = TextEditingController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadLastCodeTime();
    _listenToDatabaseChanges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification Code"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            VerificationCodeWidget(),
            const SizedBox(height: 20),
            CustomText(Colors.black, text: "Last Code verified at:", fontSize: 18),
            CustomText(Colors.green[700], text: _timeOfLastCode ?? "", fontSize: 17),
          ],
        ),
      ),
    );
  }

  Widget VerificationCodeWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PinCodeTextField(
        scrollPadding: EdgeInsets.all(20),
        mainAxisAlignment: MainAxisAlignment.center,
        appContext: context,
        length: 4,
        animationType: AnimationType.scale,
        pinTheme: PinTheme(
          fieldOuterPadding: EdgeInsets.symmetric(horizontal: 5),
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: 50,
          fieldWidth: 50,
          activeFillColor: Colors.white,
          disabledColor: Colors.grey, // تغيير لون الحقول عند تعطيلها
        ),
        animationDuration: const Duration(milliseconds: 800),
        onCompleted: (value) {
          if (!_isDisposed) {
            setState(() {
              _code = value;
              _timeOfLastCode = DateFormat('hh:mm:ss a').format(DateTime.now());
              _saveLastCodeTime(_timeOfLastCode!);
            });
          }
        },
        onChanged: (value) {
          if (!_isDisposed) {
            setState(() {
              _code = value;
            });
          }
        },
        controller: _otpController,
        enabled: true, // جعل الحقول غير قابلة للتحرير
      ),
    );
  }

  Widget CustomText(Color? color, {required String text, required double fontSize}) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, color: color),
    );
  }

  Future<void> _loadLastCodeTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_isDisposed) {
      setState(() {
        _timeOfLastCode = prefs.getString('lastCodeTime');
      });
    }
  }

  Future<void> _saveLastCodeTime(String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastCodeTime', time);
  }

  void _listenToDatabaseChanges() {
    databaseReference.child('vr-code').onValue.listen((DatabaseEvent event) {
      if (!_isDisposed) {
        setState(() {
          _vrCode = event.snapshot.value.toString();
          _otpController.text = _vrCode ?? ''; // تعيين النص في المتحكم
          _code = _vrCode; // تحديث الكود في الحقل
          _timeOfLastCode = DateFormat('hh:mm:ss a').format(DateTime.now());
          _saveLastCodeTime(_timeOfLastCode!);
        });
      }
    }).onError((error) {
      print("Error listening to vr_code changes: $error");
    });
  }
}
