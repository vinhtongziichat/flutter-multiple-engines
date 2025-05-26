import 'package:objectbox/objectbox.dart';

@Entity()
class Person {
  @Id()
  int id;
  String name;
  String language;
  String bio;
  double version;

  Person({
    this.id = 0,
    required this.name,
    required this.language,
    required this.bio,
    required this.version,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String,
      language: json['language'] as String,
      bio: json['bio'] as String,
      version: (json['version'] as num).toDouble(),
    );
  }
}