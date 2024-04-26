import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';
import 'app_state.dart';
import "package:provider/provider.dart";
import "package:url_launcher/url_launcher.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String selectedTranslation = 'William Abbot Oldfather';
  bool useRomanNumerals = false;
  List<Map<String, String>> translations = [];

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _loadTranslations() async {
    String yamlString = await DefaultAssetBundle.of(context).loadString('assets/translations.yaml');
    List<dynamic> translationsData = loadYaml(yamlString);

    setState(() {
      translations = translationsData.map<Map<String, String>>((data) {
        return {
          'title': data['title'],
          'url': data['url'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    selectedTranslation = appState.getSelectedTranslation();
    useRomanNumerals = appState.getUseRomanNumerals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Translation:',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButton<String>(
              value: selectedTranslation,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  appState.setTranslation(newValue);
                }
              },
              items: translations.map<DropdownMenuItem<String>>((Map<String, String> translation) {
                return DropdownMenuItem<String>(
                  value: translation['title'] ?? '',
                  child: Text(translation['title'] ?? ''),
                );
              }).toList(),
            ),
            ElevatedButton(
                child: const Text('View translation source'),
                onPressed: () {
                  String? url =
                      translations.firstWhere((translation) => translation['title'] == selectedTranslation)['url'];
                  if (url != null) {
                    _launchURL(url);
                  }
                }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Use Roman numerals:',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: useRomanNumerals,
                  onChanged: (bool value) {
                    appState.setUseRomanNumerals(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
