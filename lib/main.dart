import 'package:flutter/material.dart';
import 'app_state.dart';

void main() {
  runApp(const MyApp());
}

String romanize(int number) {
  List<String> romanNumbers = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  List<int> romanValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  String romanized = '';
  for (int i = 0; i < romanValues.length; i++) {
    while (number >= romanValues[i]) {
      number -= romanValues[i];
      romanized += romanNumbers[i];
    }
  }
  return romanized;
}
