import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class Person {
  @Id()
  int id;
  String name;
  String language;
  String bio;
  double version;
  String externalId;

  Person({
    this.id = 0,
    required this.name,
    required this.language,
    required this.bio,
    required this.version,
    required this.externalId,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: 0,
      name: json['name'] as String,
      language: json['language'] as String,
      bio: json['bio'] as String,
      version: (json['version'] as num).toDouble(),
      externalId: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': externalId, // Ánh xạ externalId sang 'id' để khớp với fromJson
    'name': name,
    'language': language,
    'bio': bio,
    'version': version,
  };

  static String encode(List<Person> persons) => jsonEncode(persons.map((person) => person.toJson()).toList());
}