import 'package:flutter/cupertino.dart';

class GlobalFunction {
  static String Origin = '';
  static String destination = '';
  //==================================hideKeyboard==================================//
  static void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
