import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary.dart';
import '../main.dart';

// 1. Der Suchbegriff-Provider (einfacher String)
final searchQueryProvider = StateProvider<String>((ref) => "");

// 2. Der StreamProvider, der alle Vokabeln aus der DB holt
final allVocabularyProvider = StreamProvider<List<Vocabulary>>((ref) {
  final service = ref.watch(isarServiceProvider);
  return service.listenToVocabularies();
});

// 3. Der gefilterte Provider (Kombiniert die Liste mit der Suche)
final filteredVocabularyProvider = Provider<AsyncValue<List<Vocabulary>>>((ref) {
  final allVocabsAsync = ref.watch(allVocabularyProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return allVocabsAsync.whenData((list) {
    if (query.isEmpty) return list;
    return list.where((v) => 
      v.english.toLowerCase().contains(query) || 
      v.german.toLowerCase().contains(query)
    ).toList();
  });
});