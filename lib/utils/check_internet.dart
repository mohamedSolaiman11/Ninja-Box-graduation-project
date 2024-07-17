import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class CheckInternet {
   Connectivity connectivity = Connectivity();
   Future<String> check() async {
    // Check internet connectivity
    var connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return "Check your internet connection";
    }
    else
    return "Good internet";
  }
}