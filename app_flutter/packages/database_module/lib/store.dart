// ignore_for_file: avoid_print

import 'package:path_provider/path_provider.dart';

import 'objectbox.g.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'person.dart';

class StoreBox {
  late final Store store;
  late final Box<Person> personBox;

  StoreBox._create(this.store) {
    personBox = Box<Person>(store);
  }

  static Future<StoreBox> create() async {
    final directory = await getApplicationDocumentsDirectory();
    final store = Store(
      getObjectBoxModel(),
      directory: '${directory.path}/objectbox',
    );
    final objectBox = StoreBox._create(store);
    // await objectBox._initializeWithData();
    return objectBox;
  }

  void dispose() {
    store.close();
  }

  Future<void> _initializeWithData() async {
    if (personBox.isEmpty()) {
      try {
        final jsonString = await rootBundle.loadString('packages/database_module/assets/5MB.json');
        final length = await insertData(jsonString);
        print('Initialized ObjectBox with ${length} persons from JSON');
      } catch (e) {
        print('Error initializing ObjectBox with data: $e');
      }
    }
  }

  Future<int> insertData(String jsonString) async {
    try {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final persons = jsonData.map((json) => Person.fromJson(json)).toList();
      personBox.putMany(persons);
      print('Tasks imported successfully: ${persons.length} persons added.');
      return persons.length;
    } catch (e) {
      print('Error importing tasks: $e');
      return 0;
    }
  }

  Future<bool> deleteAll() async {
    try {
      personBox.removeAll();
      print('All persons deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting persons: $e');
      return false;
    }
  }

  Future<List<Person>> getUserList() async {
    final persons = personBox.getAll();
    return persons;
  }
}