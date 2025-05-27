import 'dart:async';
import 'dart:convert';

import 'package:app_flutter/person.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Make sure your Person class is imported here

class SocketListScreen extends StatefulWidget {
  SocketListScreen({Key? key, required this.streamOut}) : super(key: key);

  final Stream<dynamic> streamOut;
  final EventChannel _streamOutChannel = EventChannel('com.ziichat/app/stream/out');
  @override
  _SocketListScreenState createState() => _SocketListScreenState();
}

class _SocketListScreenState extends State<SocketListScreen> {
  
  List<Person> _people = [];
  late StreamSubscription _subscription;

  @override
  initState() {
    super.initState();
    _subscribeToStream();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _subscribeToStream() {
    _subscription = widget.streamOut.listen(
      (dynamic event) {
        if (event == null) return;
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(event);
          final list = jsonMap['data'] as List<dynamic>? ?? [];
          final persons = list.map((json) => Person.fromJson(json)).toList();
          setState(() {
            _people = persons;
          });
        } catch (e) {
          print('Error processing stream event: $e');
        }
      },
      onError: (dynamic error) {
        print('Stream error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Data (${_people.length})'),
      ),
      body: ListView.builder(
        itemCount: _people.length,
        itemBuilder: (context, index) {
          final person = _people[index];
          return ListTile(
            leading: CircleAvatar(child: Text(person.name[0])),
            title: Text(person.name),
            subtitle: Text('${person.language} • ${person.bio}'),
            trailing: Text('v${person.version.toStringAsFixed(1)}'),
          );
        },
      ),
    );
  }
}
