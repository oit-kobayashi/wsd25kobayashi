import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _apiKeyWeather = "31c33ba0fa0fbe84f0af7ae3778818ce";
  int _counter = 0;
  int _cityIndex = 0;
  String _weatherText = "---";
  String? _iconId;

  final _cities = [
    ("大阪", "osaka"),
    ("名古屋", "nagoya"),
    ("東京", "tokyo"),
    ("フロリダ", "florida"),
    ("ロンドン", "london"),
  ];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("webシステム開発demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                      flex: 3,
                      child: DropdownMenu<int>(
                        dropdownMenuEntries: [
                          for (var i = 0; i < _cities.length; i++)
                            DropdownMenuEntry<int>(
                                value: i, label: _cities[i].$1),
                        ],
                        onSelected: (int? newVal) async {
                          setState(() {
                            if (newVal != null) _cityIndex = newVal;
                          });
                          final resp = await http.get(Uri.parse(
                              "https://api.openweathermap.org/data/2.5/weather?q=${_cities[_cityIndex].$2}&appid=$_apiKeyWeather"));
                          if (resp.statusCode == 200) {
                            final Map<String, dynamic> respMap =
                                jsonDecode(resp.body);
                            setState(() {
                              _weatherText = respMap["weather"][0]["main"];
                              _iconId = respMap["weather"][0]["icon"];
                            });
                          }
                        },
                        initialSelection: _cityIndex,
                      )),
                  Expanded(flex: 1, child: Text(_weatherText)),
                  Expanded(
                      flex: 1,
                      child: _iconId == null
                          ? Text("?")
                          : Image.network(
                              "https://openweathermap.org/img/wn/$_iconId@4x.png")),
                ])),
            Expanded(flex: 4, child: Placeholder()),
            Expanded(flex: 2, child: Placeholder()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
