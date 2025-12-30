import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary.dart';
import '../main.dart';

// 1. Welche Kategorie ist gerade im Filter ausgewählt?
final selectedCategoryProvider = StateProvider<String>((ref) => "Alle");

// 2. Der Suchbegriff
final searchQueryProvider = StateProvider<String>((ref) => "");

// 3. Alle Vokabeln aus der DB
final allVocabularyProvider = StreamProvider<List<Vocabulary>>((ref) {
  final service = ref.watch(isarServiceProvider);
  return service.listenToVocabularies();
});

// 4. Liste aller existierenden Kategorien für die Filter-Chips oben
final categoryListProvider = Provider<List<String>>((ref) {
  final allVocabs = ref.watch(allVocabularyProvider).value ?? [];
  // Wir extrahieren alle Kategorien, machen sie mit .toSet() eindeutig und sortieren sie
  final categories = allVocabs.map((v) => v.category).toSet().toList();
  categories.sort();
  return ["Alle", ...categories];
});

// 5. Die finale Liste (Filtert nach Suche UND Kategorie)
final filteredVocabularyProvider = Provider<AsyncValue<List<Vocabulary>>>((ref) {
  final allVocabsAsync = ref.watch(allVocabularyProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return allVocabsAsync.whenData((list) {
    return list.where((v) {
      final matchesSearch = v.english.toLowerCase().contains(query) || 
                           v.german.toLowerCase().contains(query);
      final matchesCategory = selectedCategory == "Alle" || v.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  });
});