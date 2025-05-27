// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:app_flutter/person.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Make sure your Person class is imported here

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({Key? key}) : super(key: key);
  final MethodChannel _appChannel = const MethodChannel('com.ziichat/app/services');
  @override
  _PersonListScreenState createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  

  List<Person> _people = [];

  @override
  initState() {
    super.initState();
    _fetchUserList();
  }

  Future<void> _fetchUserList() async {
    try {
      // Ensure the invokeMethod returns a String
      final data = await widget._appChannel.invokeMethod<String>('getUserList');
      
      // Handle null response
      if (data == null) {
        print('🍎 Error: Received null data from getUserList');
        setState(() {
          _people = [];
        });
        return;
      }

      // Parse in isolate for better performance with large datasets
      final persons = await compute(_parsePersons, data);
      
      setState(() {
        _people = persons;
      });
    } on PlatformException catch (e) {
      print('🍎 Failed to getUserList: ${e.message}');
      setState(() {
        _people = [];
      });
    } catch (e) {
      print('🍎 Unexpected error in _fetchUserList: $e');
      setState(() {
        _people = [];
      });
    }
  }

  static List<Person> _parsePersons(String jsonData) {
    try {
      final decoded = jsonDecode(jsonData);
      
      // Handle different possible JSON structures
      if (decoded == null) {
        return [];
      }
      
      // Ensure decoded is a List
      final list = decoded is List ? decoded : decoded['data'] as List<dynamic>? ?? [];
      
      return list
          .whereType<Map<String, dynamic>>() // Filter valid items
          .map((json) => Person.fromJson(json))
          .toList();
    } catch (e) {
      print('🍎 Error parsing persons: $e');
      return [];
    }
  }

  Future<void> _writeData() async {
    try {
      final jsonString = await rootBundle.loadString('packages/database_module/assets/5MB.json');
      final int length = await widget._appChannel.invokeMethod('addPersons', jsonString);
      print('Added $length persons to ObjectBox');
      await _fetchUserList(); // Refresh the list after adding data
    } catch (e) {
      print('Error initializing ObjectBox with data: $e');
    }
  }

  Future<void> _deleteAll() async {
    try {
      final bool isSuccess = await widget._appChannel.invokeMethod('deletePersons');
      print('Deleted all persons from ObjectBox: $isSuccess');
      await _fetchUserList(); // Refresh the list after deleting data
    } catch (e) {
      print('Error deleting persons from ObjectBox: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Persons (${_people.length})'),
        actions: [
          TextButton(
            onPressed: () {
              _writeData();
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () {
              _deleteAll();
            },
            child: Text('Delete'),
          ),
        ],
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
