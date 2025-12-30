import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary.dart';
import '../main.dart';

class EditVocabularyScreen extends ConsumerStatefulWidget {
  final Vocabulary vocabulary;
  const EditVocabularyScreen({super.key, required this.vocabulary});

  @override
  ConsumerState<EditVocabularyScreen> createState() => _EditVocabularyScreenState();
}

class _EditVocabularyScreenState extends ConsumerState<EditVocabularyScreen> {
  late TextEditingController _englishController;
  late TextEditingController _germanController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    // Vorhandene Daten in die Felder laden
    _englishController = TextEditingController(text: widget.vocabulary.english);
    _germanController = TextEditingController(text: widget.vocabulary.german);
    _categoryController = TextEditingController(text: widget.vocabulary.category);
  }

  void _update() async {
    final english = _englishController.text.trim();
    final german = _germanController.text.trim();
    final category = _categoryController.text.trim();

    if (english.isNotEmpty && german.isNotEmpty) {
      widget.vocabulary.english = english;
      widget.vocabulary.german = german;
      widget.vocabulary.category = category.isEmpty ? "Allgemein" : category;
      
      await ref.read(isarServiceProvider).saveVocabulary(widget.vocabulary);
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
      appBar: AppBar(
        title: const Text('Wort bearbeiten'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Inhalt anpassen",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _englishController,
              decoration: const InputDecoration(
                labelText: 'Englisch', 
                prefixIcon: Icon(Icons.language),
              ),
              textInputAction: TextInputAction.next,
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
              onSubmitted: (_) => _update(),
            ),
            
            const SizedBox(height: 40),
            
            // Nutzt automatisch das Button-Design aus main.dart
            ElevatedButton(
              onPressed: _update,
              child: const Text(
                'ÄNDERUNGEN SPEICHERN', 
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Optional: Ein Abbrechen-Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                'Abbrechen',
                style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}