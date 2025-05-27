// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';

import 'package:app_flutter/socket_list.dart';
import 'package:app_flutter/user_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "Flutter"),
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
  String _apiExecutionTime = '';
  String _userListExecutionTime = '';
  late StreamSubscription _subscription;
  late Stream<dynamic> _streamOut;
  
  @override
  void initState() {
    super.initState();
    _subscribeToStream();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _subscribeToStream() {
    _streamOut = widget._streamOutChannel.receiveBroadcastStream();
    _subscription = _streamOut.listen(
      (dynamic event) {
        if (event == null) return;
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(event);
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
        print('Stream error: $error');
      },
    );
  }

  void _execute() {
    setState(() {
      _apiString = '';
      _listString = '';
      _apiExecutionTime = '';
      _userListExecutionTime = '';
    });
    
    trackExecutionTime(
      _fetchAPI,
      functionName: '_fetchAPI',
    ).then((execution) {
      setState(() {
        _apiString = execution.result;
        _apiExecutionTime = "${ execution.duration.inMilliseconds}ms";
      });
    }).catchError((error) {
      print('Error occurred: $error');
    });

    trackExecutionTime(
      _fetchUserList,
      functionName: '_fetchUserList',
    ).then((execution) {
      setState(() {
        _listString = 'User List Length: ${execution.result}';
        _userListExecutionTime = "${execution.duration.inMilliseconds}ms";
      });
    }).catchError((error) {
      print('Error occurred: $error');
    });
  }

  void writeStream() {
    widget._streamInChannel.send({'test': "okay"});
  }

  Future<String> _fetchAPI() async {
    try {
      final data = await widget._appChannel.invokeMethod('fetchData');
      return jsonEncode(data);
    } on PlatformException catch (e) {
      print('🍎 Failed to fetch API: ${e.message}');
      return '';
    }
  }

  Future<int> _fetchUserList() async {
    try {
      final data = await widget._appChannel.invokeMethod('getUserList');
      final list = jsonDecode(data) as List<dynamic>? ?? [];
      return list.length;
    } on PlatformException catch (e) {
      print('🍎 Failed to getUserList: ${e.message}');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 4.0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonListScreen()),
              );
            },
            child: Text('User List'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SocketListScreen(streamOut: _streamOut,)),
              );
            },
            child: Text('Socket'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
            Text(
              'Fetch from DATABASE: $_userListExecutionTime',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(_listString),
            SizedBox(height: 50,),
            Text(
              'Fetch from API: $_apiExecutionTime',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(_apiString),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          _execute();
        },
        tooltip: 'Fetch',
        child: const Text("Fetch"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// Measures and prints the execution time of a given function
  Future<ExecutionResult<T>> trackExecutionTime<T>(
    Future<T> Function() function, {
    String functionName = 'Function',
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      print('$functionName executed in ${stopwatch.elapsed.inMilliseconds}ms');
      return ExecutionResult(result, stopwatch.elapsed);
    } catch (e) {
      stopwatch.stop();
      print('$functionName failed after ${stopwatch.elapsed.inMilliseconds}ms with error: $e');
      rethrow;
    }
  }
}

class ExecutionResult<T> {
  final T result;
  final Duration duration;

  ExecutionResult(this.result, this.duration);
}
