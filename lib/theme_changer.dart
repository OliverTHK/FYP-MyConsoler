import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  bool darkMode = false;
  ThemeData themeData;

  ThemeChanger(this.themeData);

  getTheme() {
    return themeData;
  }

  setTheme(ThemeData theme) {
    themeData = theme;

    notifyListeners();
  }
}
