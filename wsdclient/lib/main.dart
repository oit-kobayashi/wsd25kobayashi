import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  final _cities = [("大阪", "osaka"), ("名古屋", "nagoya"), ("東京", "tokyo")];

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
                  Expanded(flex: 3, child: Text(_cities[_cityIndex].$1)),
                  Expanded(flex: 1, child: Text("天気")),
                ])),
            Expanded(flex: 4, child: Placeholder()),
            Expanded(
                flex: 2,
                child: ElevatedButton(
                    child: Text("change the city"),
                    onPressed: () async {
                      setState(() {
                        _cityIndex = (_cityIndex + 1) % _cities.length;
                      });
                      final resp = await http.get(Uri.parse(
                          "https://api.openweathermap.org/data/2.5/weather?q=${_cities[_cityIndex].$2}&appid=$_apiKeyWeather"));
                      print(resp.body);
                    })),
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
