import 'package:isar/isar.dart';

// Diese Datei wird von Isar generiert
part 'vocabulary.g.dart';

@collection
class Vocabulary {
  Id id = Isar.autoIncrement; // Automatische ID

  late String english;
  late String german;
  
  // Metadaten für später (z.B. Sortierung nach Datum)
  DateTime createdAt = DateTime.now();

  Vocabulary({
    required this.english,
    required this.german,
  });
}