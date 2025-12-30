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

  @override
  void initState() {
    super.initState();
    // Vorhandene Daten in die Controller laden
    _englishController = TextEditingController(text: widget.vocabulary.english);
    _germanController = TextEditingController(text: widget.vocabulary.german);
  }

  void _update() async {
    final english = _englishController.text.trim();
    final german = _germanController.text.trim();

    if (english.isNotEmpty && german.isNotEmpty) {
      // Wir behalten die gleiche ID, damit Isar weiß, dass es ein Update ist
      widget.vocabulary.english = english;
      widget.vocabulary.german = german;
      
      await ref.read(isarServiceProvider).saveVocabulary(widget.vocabulary);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vokabel bearbeiten')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _englishController, decoration: const InputDecoration(labelText: 'Englisch')),
            const SizedBox(height: 10),
            TextField(controller: _germanController, decoration: const InputDecoration(labelText: 'Deutsch')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _update, child: const Text('Änderungen speichern')),
          ],
        ),
      ),
    );
  }
}