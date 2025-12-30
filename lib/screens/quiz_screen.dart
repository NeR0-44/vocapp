import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import '../providers/quiz_provider.dart';
import '../main.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _answerController = TextEditingController();
  late ConfettiController _confettiController;
  String _feedback = "";
  bool _answeredCorrectly = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _check(String correctAnswer) {
    final input = _answerController.text.trim().toLowerCase();
    setState(() {
      if (input == correctAnswer.toLowerCase()) {
        _feedback = "Hervorragend! 🎉";
        _answeredCorrectly = true;
        ref.read(audioServiceProvider).playSuccess();
      } else {
        _feedback = "Nicht ganz korrekt.\nDie Antwort ist: $correctAnswer";
        _answeredCorrectly = false;
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

  void _startQuiz() {
    ref.read(quizProvider.notifier).restart();
    setState(() => _hasStarted = true);
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // AUTO-SPEAK & CONFETTI TRIGGER
    ref.listen(quizProvider, (previous, next) {
      if (_hasStarted && next.currentWord != null && _feedback.isEmpty && previous?.currentWord != next.currentWord) {
        ref.read(ttsServiceProvider).speak(next.currentWord!.english);
      }
      if (next.isFinished) {
        _confettiController.play();
      }
    });

    if (quizState.isFinished) return _buildSuccessScreen(context);
    
    if (!_hasStarted || (quizState.remainingWords.isEmpty && !quizState.isFinished)) {
      return _buildStartScreen(context, quizState);
    }

    final word = quizState.currentWord!;
    final totalWords = ref.read(quizProvider.notifier).totalCount;
    final progress = totalWords > 0 ? (totalWords - quizState.remainingWords.length) / totalWords : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () => setState(() => _hasStarted = false)
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                color: Colors.orangeAccent,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      key: ValueKey(word.english),
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black45 : theme.colorScheme.primary.withValues(alpha: 0.1), 
                            blurRadius: 20, 
                            offset: const Offset(0, 10)
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            word.english, 
                            textAlign: TextAlign.center, 
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : theme.colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref.read(ttsServiceProvider).speak(word.english), 
                            icon: Icon(
                              Icons.volume_up_rounded, 
                              color: isDark ? Colors.white70 : theme.colorScheme.primary, 
                              size: 32
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _answerController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      hintText: 'Deine Antwort...',
                    ),
                    onSubmitted: (_) => _feedback.isEmpty ? _check(word.german) : null,
                  ),
                  const SizedBox(height: 30),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: _feedback.isEmpty
                        ? ElevatedButton(
                            key: const ValueKey('button'),
                            onPressed: () => _check(word.german),
                            child: const Text('PRÜFEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          )
                        : Column(
                            key: const ValueKey('feedback'),
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _answeredCorrectly ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _answeredCorrectly ? Colors.green : Colors.red),
                                ),
                                child: Text(
                                  _feedback, 
                                  textAlign: TextAlign.center, 
                                  style: TextStyle(
                                    fontSize: 18, 
                                    color: _answeredCorrectly ? Colors.green : Colors.red, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _continue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _answeredCorrectly ? Colors.green : theme.colorScheme.primary,
                                ),
                                child: Text(_answeredCorrectly ? 'NÄCHSTES WORT' : 'VERSTANDEN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context, dynamic quizState) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Lernen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use local start animation
              Lottie.asset(
                'assets/animations/start.json',
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 100, color: Colors.orangeAccent),
              ),
              const SizedBox(height: 20),
              Text(
                'Bereit für ein Training?', 
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent, 
                  foregroundColor: Colors.black,
                ),
                child: const Text('STARTEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use local animated green checkmark
                Lottie.asset(
                  'assets/animations/success.json',
                  width: 280,
                  height: 280,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to simple check icon if animation fails
                    return const Icon(
                      Icons.check_circle,
                      size: 120,
                      color: Colors.green,
                    );
                  },
                ),
                const Text(
                  'PERFEKT!', 
                  style: TextStyle(
                    fontSize: 48, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                    letterSpacing: 3
                  )
                ),
                const SizedBox(height: 10),
                const Text(
                  'Alle Vokabeln gemeistert.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(quizProvider.notifier).restart();
                          setState(() => _feedback = "");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, 
                          foregroundColor: theme.colorScheme.primary,
                          elevation: 10,
                        ),
                        child: const Text('NOCHMAL ÜBEN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => setState(() => _hasStarted = false), 
                        child: const Text('Zum Startbildschirm', style: TextStyle(color: Colors.white70, fontSize: 16))
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.orange, Colors.blue, Colors.white, Colors.yellow],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }
}