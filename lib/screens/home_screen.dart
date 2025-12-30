import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocabulary_provider.dart';
import '../main.dart'; // Import für den isarServiceProvider
import 'add_vocabulary_screen.dart';
import 'quiz_screen.dart';
import 'edit_vocabulary_screen.dart'; // NEU: Import für den Edit-Screen

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabularyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VocApp - Meine Vokabeln'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Quiz starten',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QuizScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: vocabAsync.when(
        data: (vocabs) => vocabs.isEmpty
            ? const Center(child: Text('Noch keine Vokabeln gelernt.'))
            : ListView.builder(
                itemCount: vocabs.length,
                itemBuilder: (context, index) {
                  final v = vocabs[index];
                  
                  // NEU: Dismissible ermöglicht das Wischen zum Löschen
                  return Dismissible(
                    key: Key(v.id.toString()),
                    direction: DismissDirection.endToStart, // Von rechts nach links
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    // Bestätigung des Löschvorgangs
                    onDismissed: (direction) {
                      ref.read(isarServiceProvider).deleteVocabulary(v.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${v.english} gelöscht')),
                      );
                    },
                    child: ListTile(
                      title: Text(v.english),
                      subtitle: Text(v.german),
                      trailing: const Icon(Icons.edit, size: 20, color: Colors.grey),
                      onTap: () {
                        // NEU: Navigation zum Edit-Screen beim Drauftippen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditVocabularyScreen(vocabulary: v),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fehler: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddVocabularyScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}