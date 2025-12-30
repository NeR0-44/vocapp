import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary.dart';
import '../main.dart'; // Wichtig, um auf den isarServiceProvider zuzugreifen

// Dieser Provider "beobachtet" die Datenbank und gibt uns immer die aktuelle Liste
final vocabularyListProvider = StreamProvider<List<Vocabulary>>((ref) {
  final service = ref.watch(isarServiceProvider);
  return service.listenToVocabularies();
});