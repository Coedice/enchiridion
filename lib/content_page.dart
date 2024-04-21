import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'main.dart';
import "package:provider/provider.dart";
import 'app_state.dart';

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
  late List<dynamic> contentText = [];
  bool scrolled = false;
  String selectedTranslation = "";
  bool useRomanNumerals = false;

  @override
  void initState() {
    super.initState();
    _loadChapterTitles();
    _loadTranslationText();
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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    selectedTranslation = appState.getSelectedTranslation();
    useRomanNumerals = appState.getUseRomanNumerals();

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
