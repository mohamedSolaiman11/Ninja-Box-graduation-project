import 'package:flutter/material.dart';
void goToPageOnly(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) {
    return page;
  })
  );
}