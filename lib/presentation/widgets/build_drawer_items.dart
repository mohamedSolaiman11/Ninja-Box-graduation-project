import 'package:flutter/material.dart';

class BuildDrawerRowItems extends StatelessWidget {
  const BuildDrawerRowItems({
    super.key, required this.text, required this.icon,required this.onTap
  });
  final String text;
  final IconData icon;
  final  Function() onTap;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.width*.16,
        
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
          ),
          margin: EdgeInsets.symmetric(horizontal: size.width*.025,vertical: size.height*.009),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(onPressed:(){} , icon: Icon(icon,color: Colors.
                black,size: 25,)),
              Text(text,style: TextStyle(color: Colors.black,fontSize: 19),),
        
            ],
          ),
        ),
      ),
    );
  }
}