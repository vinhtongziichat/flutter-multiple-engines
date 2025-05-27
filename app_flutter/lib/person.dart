import 'dart:convert';

class Person {
  String id;
  String name;
  String language;
  String bio;
  double version;

  Person({
    required this.id,
    required this.name,
    required this.language,
    required this.bio,
    required this.version,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id:json['id'] as String,
      name: json['name'] as String,
      language: json['language'] as String,
      bio: json['bio'] as String,
      version: (json['version'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'language': language,
    'bio': bio,
    'version': version,
  };

  static String encode(List<Person> persons) => jsonEncode(persons.map((person) => person.toJson()).toList());
}