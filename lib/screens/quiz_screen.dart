import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../main.dart'; // WICHTIG: Import für den ttsServiceProvider

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
        _feedback = "Hervorragend! 🎉";
        _answeredCorrectly = true;
        // SOUND BEI ERFOLG
        ref.read(audioServiceProvider).playSuccess();
      } else {
        _feedback = "Nicht ganz korrekt.\nDie Antwort ist: $correctAnswer";
        _answeredCorrectly = false;
        // SOUND BEI FEHLER
        ref.read(audioServiceProvider).playError();
      }
    });
  }

  void _continue() {
    ref.read(quizProvider.notifier).checkAnswer(_answeredCorrectly);
    setState(() {
      _answerController.clear();
      _feedback = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    // AUTO-SPEAK: Liest das Wort automatisch vor, wenn ein neues erscheint
    ref.listen(quizProvider, (previous, next) {
      if (next.currentWord != null && _feedback.isEmpty && previous?.currentWord != next.currentWord) {
        ref.read(ttsServiceProvider).speak(next.currentWord!.english);
      }
    });

    // 1. Fall: Keine Vokabeln vorhanden
    if (quizState.remainingWords.isEmpty && !quizState.isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Füge erst Vokabeln hinzu.')),
      );
    }

    // 2. Fall: Alle Vokabeln geschafft! (Erfolgs-Screen)
    if (quizState.isFinished) {
      return _buildSuccessScreen(context);
    }

    // 3. Fall: Das eigentliche Quiz
    final word = quizState.currentWord!;
    
    // Fortschritt berechnen
    final totalWords = ref.read(quizProvider.notifier).totalCount;
    final progress = totalWords > 0 ? (totalWords - quizState.remainingWords.length) / totalWords : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Training', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Fortschrittsbalken oben
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.indigo.withAlpha(50),
              color: Colors.orangeAccent,
              minHeight: 8,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    "Wie übersetzt du das?",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 20),
                  // Die Vokabel-Karte
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withAlpha(20),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          word.english,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.indigo),
                        ),
                        const SizedBox(height: 12),
                        // NEU: Lautsprecher-Button zum manuellen Vorlesen
                        IconButton(
                          onPressed: () => ref.read(ttsServiceProvider).speak(word.english),
                          icon: const Icon(Icons.volume_up_rounded, color: Colors.indigo, size: 32),
                          tooltip: 'Anhören',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Eingabefeld
                  TextField(
                    controller: _answerController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Deine Antwort...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    onSubmitted: (_) => _feedback.isEmpty ? _check(word.german) : null,
                  ),
                  const SizedBox(height: 30),
                  // Feedback & Buttons
                  if (_feedback.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _check(word.german),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('PRÜFEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _answeredCorrectly ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _answeredCorrectly ? Colors.green : Colors.red),
                      ),
                      child: Text(
                        _feedback,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18, 
                          color: _answeredCorrectly ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _answeredCorrectly ? Colors.green : Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(_answeredCorrectly ? 'NÄCHSTES WORT' : 'VERSTANDEN', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, size: 120, color: Colors.orangeAccent),
            const SizedBox(height: 30),
            const Text('Großartig!', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Du hast alle Wörter gewusst.', style: TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => ref.read(quizProvider.notifier).restart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('NOCHMAL ÜBEN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Zurück zur Liste', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}