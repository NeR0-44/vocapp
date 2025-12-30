import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/isar_service.dart';
import 'screens/home_screen.dart'; 
import 'services/tts_service.dart';
import 'services/audio_service.dart'; 

final isarServiceProvider = Provider((ref) => IsarService());
final ttsServiceProvider = Provider((ref) => TtsService());
final audioServiceProvider = Provider((ref) => AudioService());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();
  await isarService.openDb();

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // HIER DIE ÄNDERUNG:
      home: const HomeScreen(), 
    );
  }
}