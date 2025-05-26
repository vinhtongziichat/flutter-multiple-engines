// // ignore_for_file: avoid_print

// import 'objectbox.g.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'person.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:objectbox/objectbox.dart';

// class StoreBox {
//   late final Store store;
//   late final Box<Person> personBox;

//   StoreBox._create(this.store) {
//     personBox = Box<Person>(store);
//   }

//   static Future<StoreBox> create() async {
//     final docsDir = await getApplicationDocumentsDirectory();
//     final store = await openStore(directory: p.join(docsDir.path, "obx-example"));
//     final objectBox = StoreBox._create(store);
//     await objectBox._initializeWithData();
//     return objectBox;
//   }

//   void dispose() {
//     store.close();
//   }

//   Future<void> _initializeWithData() async {
//     if (personBox.isEmpty()) {
//       try {
//         final jsonString = await rootBundle.loadString('assets/5MB.json');
//         final List<dynamic> jsonData = jsonDecode(jsonString);
//         final persons = jsonData.map((json) => Person.fromJson(json)).toList();
//         personBox.putMany(persons);
//         print('Initialized ObjectBox with ${persons.length} persons from JSON');
//       } catch (e) {
//         print('Error initializing ObjectBox with data: $e');
//       }
//     }
//   }

//   Future<void> importTasksFromJson() async {
//     try {
//       final jsonString = await rootBundle.loadString('assets/5MB.json');
//       final List<dynamic> jsonData = jsonDecode(jsonString);
//       final persons = jsonData.map((json) => Person.fromJson(json)).toList();
//       personBox.putMany(persons);
//       print('Tasks imported successfully: ${persons.length} persons added.');
//     } catch (e) {
//       print('Error importing tasks: $e');
//     }
//   }

//   Future<List<dynamic>> getUserList() async {
//     final persons = personBox.getAll();
//     return persons;
//   }
// }