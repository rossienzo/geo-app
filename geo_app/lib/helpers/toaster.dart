import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toaster {
  static void showToast(String message,
      {color = Colors.black, backgroundColor = Colors.amber}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: color,
        backgroundColor: backgroundColor,
        fontSize: 16.0);
  }
}
