import 'package:isar/isar.dart';

part 'vocabulary.g.dart';

@collection
class Vocabulary {
  Id id = Isar.autoIncrement;

  late String english;
  late String german;
  
  // NEU: Jedes Wort gehört nun zu einer Kategorie
  @Index()
  String category = "Allgemein";

  DateTime createdAt = DateTime.now();

  Vocabulary({
    required this.english,
    required this.german,
    this.category = "Allgemein",
  });
}