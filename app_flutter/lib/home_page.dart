// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;
  final MethodChannel _appChannel = MethodChannel('com.ziichat/app/services');
  final EventChannel _streamOutChannel = EventChannel('com.ziichat/app/stream/out');
  final BasicMessageChannel _streamInChannel = BasicMessageChannel('com.ziichat/app/stream/in', JSONMessageCodec());
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _apiString = '';
  String _listString = '';
  String _streamMessage = '';

  @override
  void initState() {
    super.initState();
    widget._streamOutChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event == null) return;
        try {
          Map<String, dynamic> jsonMap = jsonDecode(event);
          final content = jsonMap['content'];
          if (content is String) {
            setState(() {
              _streamMessage = content;
            });
          }
        } catch (e) {
          print('Error processing stream event: $e');
        }
      },
      onError: (dynamic error) {
        
      },
    );
  }

  void _incrementCounter() {
    setState(() {
      _apiString = '';
      _listString = '';
    });
    _fetchData();
  }

  void writeStream() {
    widget._streamInChannel.send({'test': "okay"});
  }

  Future<void> _fetchData() async {
    try {
      final list = await widget._appChannel.invokeMethod('getUserList');
      setState(() {
        _listString = jsonEncode(list);
      });
      final data = await widget._appChannel.invokeMethod('fetchData');
      setState(() {
        _apiString = jsonEncode(data);
      });
    } on PlatformException catch (e) {
      print('Failed to fetch data: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'WebSocket:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(_streamMessage),
            SizedBox(height: 50,),
            const Text(
              'Fetch from API:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(_apiString),
            SizedBox(height: 50,),
            const Text(
              'Fetch from DATABASE:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(_listString),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Text("Fetch"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
