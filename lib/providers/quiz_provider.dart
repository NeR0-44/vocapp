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

class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() {
    // HIER WAR DER FEHLER: Wir nutzen jetzt allVocabularyProvider
    final allWords = ref.watch(allVocabularyProvider).value ?? [];
    
    if (allWords.isEmpty) {
      return QuizState(remainingWords: []);
    }
    
    final shuffled = List<Vocabulary>.from(allWords)..shuffle();
    return QuizState(
      remainingWords: shuffled,
      currentWord: shuffled.first,
    );
  }

  void checkAnswer(bool wasCorrect) {
    if (!wasCorrect) {
      _pickNextWord(removeCurrent: false);
    } else {
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
      final nextWord = currentList[Random().nextInt(currentList.length)];
      state = QuizState(remainingWords: currentList, currentWord: nextWord);
    }
  }

  void restart() {
    ref.invalidateSelf();
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});