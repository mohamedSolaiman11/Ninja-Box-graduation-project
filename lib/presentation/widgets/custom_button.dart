import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  const CustomButton(BuildContext context,{required this.text,required this.backColor, required this.widget});
  final Widget widget;
  final Color backColor;
  final String text;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  widget),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        width: 300,
        height: 75,
        decoration: BoxDecoration(
          color: backColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
      ),
    );
  }
}

