import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enchiridion',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          background: Colors.white,
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          onBackground: Colors.black,
          onSurface: Colors.black,
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<String> chapters = [];
  bool useRomanNumerals = false;

  void _loadChapters() async {
    String yamlString = await DefaultAssetBundle.of(context).loadString('assets/chapters.yaml');
    List<dynamic> chaptersData = jsonDecode(jsonEncode(loadYaml(yamlString)));

    setState(() {
      chapters = chaptersData.map((data) => data.toString()).toList();
    });
  }

  void _getUseRomanNumerals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      useRomanNumerals = prefs.getBool('useRomanNumerals') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChapters();
    _getUseRomanNumerals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text("Enchiridion"),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: const Icon(Icons.settings),
          )
        ],
      ),
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentPage(chapter: i),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black,
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              useRomanNumerals ? romanize(i + 1) : "${i + 1}",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: AutoSizeText(
                              chapters[i],
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: chapters.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.3,
                crossAxisCount: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentPage extends StatefulWidget {
  final int chapter;

  const ContentPage({Key? key, required this.chapter}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final _scrollToKey = GlobalKey();

  final ScrollController _controller = ScrollController();
  late List<String> chapterTitles = [];
  late String selectedTranslation = "";
  late List<dynamic> contentText = [];
  bool scrolled = false;
  bool useRomanNumerals = false;

  @override
  void initState() {
    super.initState();
    _loadChapterTitles();
    _getSelectedTranslation();
    _loadTranslationText();
    _getUseRomanNumerals();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (!scrolled) {
        _scrollToWidget();
        scrolled = true;
      }
    });
  }

  void _loadChapterTitles() async {
    String yamlString = await DefaultAssetBundle.of(context).loadString('assets/chapters.yaml');
    List<dynamic> chaptersData = jsonDecode(jsonEncode(loadYaml(yamlString)));
    List<String> chapters = chaptersData.map((data) => data.toString()).toList();

    setState(() {
      chapterTitles = chapters.toList();
    });
  }

  void _getSelectedTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTranslation = prefs.getString('selectedTranslation') ?? 'William Abbott Oldfather';
    });
  }

  void _loadTranslationText() async {
    String yamlString = await DefaultAssetBundle.of(context).loadString('assets/translations.yaml');
    List<dynamic> translationsData = jsonDecode(jsonEncode(loadYaml(yamlString)));

    for (var translation in translationsData) {
      if (translation['title'] == selectedTranslation) {
        setState(() {
          contentText = translation['chapters'];
        });
      }
    }
  }

  void _scrollToWidget() {
    final renderObject = _scrollToKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final safeArea = MediaQuery.of(context).padding;
      final offset = renderObject.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
      _controller.position.jumpTo(offset.dy - kToolbarHeight - safeArea.top);
    }
  }

  void _getUseRomanNumerals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      useRomanNumerals = prefs.getBool('useRomanNumerals') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    scrolled = false;
    List<Widget> content = [];
    for (int i = 0; i < contentText.length; i++) {
      GlobalKey? key = i == widget.chapter ? _scrollToKey : null;
      content.add(Text(
        useRomanNumerals ? romanize(i + 1) : "${i + 1}",
        style: const TextStyle(
          fontSize: 40,
        ),
        key: key,
      ));
      content.add(Text(
        chapterTitles[i],
        style: const TextStyle(
          fontSize: 20,
        ),
      ));
      content.add(
        SelectableText(
          contentText[i],
          textAlign: TextAlign.left,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enchiridion"),
      ),
      body: SingleChildScrollView(
        controller: _controller,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Column(
          children: [
            ...content,
            SizedBox(height: MediaQuery.of(context).size.height / 2),
          ],
        ),
      ),
    );
  }
}

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
    _loadSelectedTranslation();
    _loadUseRomanNumerals();
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

  Future<void> _loadSelectedTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      var savedTranslation = prefs.getString('selectedTranslation') ?? 'William Abbott Oldfather';

      // if the translation is not in the list, use the default
      if (!translations.any((translation) => translation['title'] == savedTranslation)) {
        savedTranslation = 'William Abbott Oldfather';

        // Save the default translation
        _saveSelectedTranslation(savedTranslation);
      }

      selectedTranslation = savedTranslation;
    });
  }

  Future<void> _saveSelectedTranslation(String translation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTranslation', translation);
  }

  @override
  Widget build(BuildContext context) {
    _loadSelectedTranslation();
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
                  _saveSelectedTranslation(newValue);
                  setState(() {
                    selectedTranslation = newValue;
                  });
                }
              },
              items: translations.map<DropdownMenuItem<String>>((Map<String, String> translation) {
                return DropdownMenuItem<String>(
                  value: translation['title'] ?? '',
                  child: Text(translation['title'] ?? ''),
                );
              }).toList(),
            ),
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
                    setState(() {
                      useRomanNumerals = value;
                      _saveUseRomanNumerals(value);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUseRomanNumerals(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useRomanNumerals', value);
  }

  Future<void> _loadUseRomanNumerals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      useRomanNumerals = prefs.getBool('useRomanNumerals') ?? false;
    });
  }
}
