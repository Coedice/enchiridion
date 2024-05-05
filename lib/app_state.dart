import 'package:provider/provider.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter/material.dart';
import 'home_page.dart';

class MyAppState extends ChangeNotifier {
  var _selectedTranslation = "William Abbott Oldfather";
  var _useRomanNumerals = false;

  String getSelectedTranslation() {
    SharedPreferences.getInstance().then((prefs) {
      _selectedTranslation = prefs.getString("selectedTranslation") ?? 'William Abbott Oldfather';
    });

    return _selectedTranslation;
  }

  bool getUseRomanNumerals() {
    SharedPreferences.getInstance().then((prefs) {
      _useRomanNumerals = prefs.getBool("useRomanNumerals") ?? false;
    });

    return _useRomanNumerals;
  }

  void setUseRomanNumerals(bool value) async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("useRomanNumerals", value);
      _useRomanNumerals = value;
      notifyListeners();
    });
  }

  void setTranslation(String translation) async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("selectedTranslation", translation);
      _selectedTranslation = translation;
      notifyListeners();
    });
  }

  MyAppState();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyAppState appState = MyAppState();

    return ChangeNotifierProvider(
      create: (context) => appState,
      child: MaterialApp(
        title: 'Enchiridion',
        theme: ThemeData(
          colorScheme: const ColorScheme(
            background: Colors.black,
            brightness: Brightness.dark,
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.white,
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.black,
            onBackground: Colors.white,
            onSurface: Colors.white,
            surface: Colors.black,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
