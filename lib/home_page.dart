import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'settings_page.dart';
import 'content_page.dart';
import 'main.dart';
import 'app_state.dart';
import "package:provider/provider.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<String> chapters = [];
  bool useRomanNumerals = false;

  void _loadChapters() async {
    String yamlString = await DefaultAssetBundle.of(context).loadString('assets/chapters.yaml');
    List<dynamic> chaptersData = jsonDecode(jsonEncode(loadYaml(yamlString)));

    setState(() {
      chapters = chaptersData.map((data) => data.toString()).toList();
    });
  }

  @override
  void initState() {
    print("GGG ran _initState");
    super.initState();
    _loadChapters();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    useRomanNumerals = appState.getUseRomanNumerals();

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
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16.0),
              sliver: SliverGrid(
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
            ),
          ],
        ),
      ),
    );
  }
}
