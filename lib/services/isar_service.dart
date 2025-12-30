import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/vocabulary.dart';

class IsarService {
  late Isar isar;

  Future<void> openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      isar = await Isar.open(
        [VocabularySchema],
        directory: dir.path,
      );
    }
  }

  // Speichert ODER aktualisiert eine Vokabel
  Future<void> saveVocabulary(Vocabulary vocab) async {
    await isar.writeTxn(() async {
      await isar.vocabularys.put(vocab);
    });
  }

  Stream<List<Vocabulary>> listenToVocabularies() {
    return isar.vocabularys.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  // Löscht eine Vokabel anhand der ID
  Future<void> deleteVocabulary(int id) async {
    await isar.writeTxn(() async {
      await isar.vocabularys.delete(id);
    });
  }
}