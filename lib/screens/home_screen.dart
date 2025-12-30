import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocabulary_provider.dart';
import '../main.dart';
import 'add_vocabulary_screen.dart';
import 'quiz_screen.dart';
import 'edit_vocabulary_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wir beobachten jetzt den GEFILTERTEN Provider
    final vocabAsync = ref.watch(filteredVocabularyProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VocApp'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QuizScreen()),
            ),
          ),
        ],
        // Suchleiste direkt unter der AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Suchen...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withAlpha(200),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: vocabAsync.when(
        data: (vocabs) => vocabs.isEmpty
            ? Center(
                child: Text(searchQuery.isEmpty 
                  ? 'Noch keine Vokabeln.' 
                  : 'Nichts gefunden.'),
              )
            : ListView.builder(
                itemCount: vocabs.length,
                itemBuilder: (context, index) {
                  final v = vocabs[index];
                  return Dismissible(
                    key: Key(v.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      ref.read(isarServiceProvider).deleteVocabulary(v.id);
                    },
                    child: ListTile(
                      title: Text(v.english, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(v.german),
                      trailing: const Icon(Icons.edit, size: 18),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EditVocabularyScreen(vocabulary: v)),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fehler: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddVocabularyScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}