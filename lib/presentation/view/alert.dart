import 'package:flutter/material.dart';
import 'package:graduation_project2024/presentation/view/rules_page.dart';

import 'home_page.dart';
class Alert extends StatefulWidget {
  const Alert({super.key});

  @override
  State<Alert> createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        title: Text("NINJA BOX ALERT",style: TextStyle(color: Colors.white,fontSize: 25),),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(height: size.height*.01,),
          SizedBox(
            width: double.infinity,
            height: size.height*.3,
            child: Image.asset("assets/images/real_dark_door.png"),
          ),
          Container(
            width: double.infinity,
            height: size.height*.1,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text("Someone try to open the box !!",style: TextStyle(color: Colors.white,fontSize: 23,fontWeight: FontWeight.bold),)),
          ),
          SizedBox(height: size.height*.08,),
          Container(
              width: double.infinity,
              height: size.height*.15,
              child: Image.asset("assets/icons/security.png",width: 120,)),
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushReplacement(
                MaterialPageRoute (
                  builder: (BuildContext context) => const RulesPage(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: size.height*.1,
              margin: EdgeInsets.symmetric(vertical: 50,horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text("Check rules!",style: TextStyle(decorationColor: Colors.white,decorationThickness: 1.5,decorationStyle: TextDecorationStyle.solid,decoration: TextDecoration.underline,color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),),
            ),
          ),

        ],
      ),
    );
  }
}
