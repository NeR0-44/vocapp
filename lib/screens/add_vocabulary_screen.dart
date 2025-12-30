import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary.dart';
import '../main.dart';

class AddVocabularyScreen extends ConsumerStatefulWidget {
  const AddVocabularyScreen({super.key});

  @override
  ConsumerState<AddVocabularyScreen> createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends ConsumerState<AddVocabularyScreen> {
  final _englishController = TextEditingController();
  final _germanController = TextEditingController();
  final _categoryController = TextEditingController(text: "Allgemein");

  void _save() async {
    final english = _englishController.text.trim();
    final german = _germanController.text.trim();
    final category = _categoryController.text.trim();

    if (english.isNotEmpty && german.isNotEmpty) {
      final newVocab = Vocabulary(
        english: english, 
        german: german,
        category: category.isEmpty ? "Allgemein" : category,
      );
      
      await ref.read(isarServiceProvider).saveVocabulary(newVocab);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _englishController.dispose();
    _germanController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Nutzt automatisch den Hintergrund aus dem Theme
      appBar: AppBar(
        title: const Text('Neues Wort'),
      ),
      body: SingleChildScrollView( // Verhindert Fehler, wenn die Tastatur hochklappt
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Details eingeben",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Die Textfelder nutzen jetzt das globale inputDecorationTheme
            TextField(
              controller: _englishController,
              decoration: const InputDecoration(
                labelText: 'Englisch', 
                prefixIcon: Icon(Icons.language),
              ),
              textInputAction: TextInputAction.next, // Springt zum nächsten Feld
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _germanController,
              decoration: const InputDecoration(
                labelText: 'Deutsch', 
                prefixIcon: Icon(Icons.translate),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategorie', 
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            
            const SizedBox(height: 40),
            
            // Der Button übernimmt automatisch das Styling aus main.dart
            ElevatedButton(
              onPressed: _save,
              child: const Text(
                'WORT SPEICHERN', 
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}