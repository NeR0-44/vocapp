import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/isar_service.dart';
import 'services/tts_service.dart';
import 'services/audio_service.dart';
import 'screens/main_screen.dart';
import 'providers/theme_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final isarServiceProvider = Provider((ref) => IsarService());
final ttsServiceProvider = Provider((ref) => TtsService());
final audioServiceProvider = Provider((ref) => AudioService());

void main() async {
  // 1. Splash Screen beibehalten, während wir laden
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Datenbank initialisieren
  final isarService = IsarService();
  await isarService.openDb();

  // 3. Wenn alles fertig ist, Splash Screen entfernen
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    const Color brandIndigo = Colors.indigo;

    return MaterialApp(
      title: 'VocApp',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandIndigo,
          brightness: Brightness.light,
          primary: brandIndigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandIndigo,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          // KORREKTUR: withValues statt withOpacity
          indicatorColor: brandIndigo.withValues(alpha: 0.2),
          backgroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandIndigo,
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1C2E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandIndigo,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          // KORREKTUR: withValues statt withOpacity
          indicatorColor: brandIndigo.withValues(alpha: 0.5),
          backgroundColor: const Color(0xFF1A1A1A),
        ),
      ),
      themeMode: themeMode, 
      home: const MainScreen(),
    );
  }
}