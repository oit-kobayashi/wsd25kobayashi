import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  int _cityIndex = 0;
  Uint8List? _imgData;
  String? _imgUrl;
  String _weatherText = "---";
  String? _iconId;
  String _note = "";

  final _cities = [
    ("大阪", "osaka"),
    ("名古屋", "nagoya"),
    ("東京", "tokyo"),
    ("フロリダ", "florida"),
    ("ロンドン", "london"),
  ];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) {
      setState(() {
        final int? i = sp.getInt('city');
        if (i != null) _cityIndex = i;
      });
    });
    FirebaseFirestore.instance.collection('collection').get().then((q) {
      for (var i in q.docs) {
        print(i.data());
      }
      ;
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
                          final sp = await SharedPreferences.getInstance();
                          sp.setInt('city', _cityIndex);
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
            Expanded(
                flex: 4,
                child: _imgUrl != null
                    ? Image.network(_imgUrl!)
                    : (_imgData != null
                        ? Image.memory(_imgData!)
                        : Placeholder())),
            Expanded(flex: 1, child: Text(_note)),
            Expanded(
                flex: 1,
                child: TextField(
                  onSubmitted: (newText) async {
                    setState(() {
                      _note = newText;
                    });
                    final db = FirebaseFirestore.instance;
                    await db.collection("collection").add({'note': _note});
                  },
                )),
            Expanded(flex: 2, child: Placeholder()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ImagePicker()
              .pickImage(source: ImageSource.gallery)
              .then((xfile) async {
            if (xfile == null) return;
            Uint8List img = await xfile.readAsBytes();
            setState(() {
              _imgData = img;
              _imgUrl = null;
            });

            final uri = Uri.parse('https://wsdserver.onrender.com/v1/photos');
            final req = http.MultipartRequest('POST', uri);
            final mpf = http.MultipartFile.fromBytes('file', img,
                filename: 'photo.jpg', contentType: MediaType('image', 'jpeg'));
            req.files.add(mpf);
            final resp = await req.send();
            final respStr = await resp.stream.bytesToString();
            final respMap = jsonDecode(respStr);
            setState(() {
              _imgUrl = 'https://wsdserver.onrender.com${respMap["url"]}';
              _imgData = null;
            });
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.image),
      ),
    );
  }
}
