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

  void _save() async {
    final english = _englishController.text.trim();
    final german = _germanController.text.trim();

    if (english.isNotEmpty && german.isNotEmpty) {
      final newVocab = Vocabulary(english: english, german: german);
      
      // HIER WAR DER FEHLER: addVocabulary -> saveVocabulary
      await ref.read(isarServiceProvider).saveVocabulary(newVocab);

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _englishController.dispose();
    _germanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Word')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _englishController,
              decoration: const InputDecoration(labelText: 'English'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _germanController,
              decoration: const InputDecoration(labelText: 'German (Translation)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Vocabulary'),
            ),
          ],
        ),
      ),
    );
  }
}