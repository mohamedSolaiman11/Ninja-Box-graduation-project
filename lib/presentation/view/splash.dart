import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project2024/presentation/view/admin.dart';


class Splash extends StatefulWidget {
  static String id = "splash";
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Delay navigation to the next screen after 5 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Admin()),
      );
    });
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 300,
                child: Image.asset("assets/images/branding1.png")),
            const SizedBox(height: 10.0),
            animate(),
          ],
        ),
      ),
    );
  }
}
Widget animate(){
  return DefaultTextStyle(
    style: const TextStyle(
        color: Colors.black,
        fontSize: 40.0,
        fontWeight: FontWeight.bold
    ),
    child: AnimatedTextKit(
      animatedTexts: [
        WavyAnimatedText('NINJA BOX '),
      ],
      isRepeatingAnimation: true,
    ),
  );
}
