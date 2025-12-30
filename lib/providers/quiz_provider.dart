import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vocabulary_provider.dart';
import '../models/vocabulary.dart';

class QuizState {
  final List<Vocabulary> remainingWords;
  final Vocabulary? currentWord;
  final bool isFinished;

  QuizState({required this.remainingWords, this.currentWord, this.isFinished = false});
}

class QuizNotifier extends Notifier<QuizState> {
  // Wir merken uns die Gesamtzahl der Wörter beim Start
  int _totalCount = 0;
  int get totalCount => _totalCount;

  @override
  QuizState build() {
    final allWords = ref.watch(allVocabularyProvider).value ?? [];
    
    if (allWords.isEmpty) {
      _totalCount = 0;
      return QuizState(remainingWords: []);
    }
    
    _totalCount = allWords.length;
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