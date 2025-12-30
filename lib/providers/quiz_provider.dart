import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vocabulary_provider.dart';
import '../models/vocabulary.dart';

// Wir definieren den Zustand des Quizzes
class QuizState {
  final List<Vocabulary> remainingWords;
  final Vocabulary? currentWord;
  final bool isFinished;

  QuizState({
    required this.remainingWords, 
    this.currentWord, 
    this.isFinished = false
  });
}

// Der Notifier verwaltet die Logik
class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() {
    // Am Anfang holen wir alle Vokabeln aus der DB
    final allWords = ref.watch(vocabularyListProvider).value ?? [];
    
    if (allWords.isEmpty) {
      return QuizState(remainingWords: []);
    }
    
    // Wir mischen die Liste und wählen das erste Wort
    final shuffled = List<Vocabulary>.from(allWords)..shuffle();
    return QuizState(
      remainingWords: shuffled,
      currentWord: shuffled.first,
    );
  }

  void checkAnswer(bool wasCorrect) {
    if (!wasCorrect) {
      // Bei einem Fehler: Wort bleibt in der Liste, wir würfeln nur neu
      _pickNextWord(removeCurrent: false);
    } else {
      // Richtig beantwortet: Wort aus der Liste entfernen
      _pickNextWord(removeCurrent: true);
    }
  }

  void _pickNextWord({required bool removeCurrent}) {
    final currentList = List<Vocabulary>.from(state.remainingWords);
    
    if (removeCurrent && state.currentWord != null) {
      currentList.removeWhere((v) => v.id == state.currentWord!.id);
    }

    if (currentList.isEmpty) {
      state = QuizState(remainingWords: [], isFinished: true);
    } else {
      // Neues zufälliges Wort aus der Restliste
      final nextWord = currentList[Random().nextInt(currentList.length)];
      state = QuizState(remainingWords: currentList, currentWord: nextWord);
    }
  }

  void restart() {
    ref.invalidateSelf(); // Startet den Provider (und damit build()) neu
  }
}

// Der Provider, den wir im UI nutzen
final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});