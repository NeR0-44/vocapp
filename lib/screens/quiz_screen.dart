import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _answerController = TextEditingController();
  String _feedback = "";
  bool _answeredCorrectly = false;

  void _check(String correctAnswer) {
    final input = _answerController.text.trim().toLowerCase();
    setState(() {
      if (input == correctAnswer.toLowerCase()) {
        _feedback = "Richtig! 🎉";
        _answeredCorrectly = true;
      } else {
        _feedback = "Leider falsch. Richtig: $correctAnswer";
        _answeredCorrectly = false;
      }
    });
  }

  void _continue() {
    // Hier sagen wir dem Provider, ob er das Wort entfernen soll oder nicht
    ref.read(quizProvider.notifier).checkAnswer(_answeredCorrectly);
    
    setState(() {
      _answerController.clear();
      _feedback = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    // 1. Fall: Keine Vokabeln vorhanden
    if (quizState.remainingWords.isEmpty && !quizState.isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Bitte füge erst Vokabeln hinzu.')),
      );
    }

    // 2. Fall: Alle Vokabeln geschafft!
    if (quizState.isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Glückwunsch!')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              const Text('Alle Wörter gelernt!', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.read(quizProvider.notifier).restart(),
                child: const Text('Nochmal starten'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zurück zur Liste'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Fall: Das eigentliche Quiz
    final word = quizState.currentWord!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Noch ${quizState.remainingWords.length} Wörter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Was heißt das auf Deutsch?'),
            const SizedBox(height: 10),
            Text(
              word.english,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _answerController,
              autofocus: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onSubmitted: (_) => _feedback.isEmpty ? _check(word.german) : null,
            ),
            const SizedBox(height: 20),
            if (_feedback.isEmpty)
              ElevatedButton(
                onPressed: () => _check(word.german),
                child: const Text('Prüfen'),
              )
            else ...[
              Text(
                _feedback,
                style: TextStyle(
                  fontSize: 18, 
                  color: _answeredCorrectly ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _continue,
                child: Text(_answeredCorrectly ? 'Weiter' : 'Verstanden'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}