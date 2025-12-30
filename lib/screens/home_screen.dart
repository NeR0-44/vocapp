import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocabulary_provider.dart';
import '../main.dart';
import 'add_vocabulary_screen.dart';
import 'quiz_screen.dart';
import 'edit_vocabulary_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(filteredVocabularyProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        // Neutraler Titel für alle Themen
        title: const Text('VocApp', 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo, // Indigo wirkt oft universeller als Hellblau
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, size: 30), // Ein "Gehirn"-Icon passt super zum Lernen
            tooltip: 'Quiz starten',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QuizScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // HEADER BEREICH
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: 'Begriff suchen...',
                    prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                vocabAsync.when(
                  data: (vocabs) => Text(
                    '${vocabs.length} Vokabeln in deiner Sammlung',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: vocabAsync.when(
              data: (vocabs) => vocabs.isEmpty
                  ? _buildEmptyState(searchQuery)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: vocabs.length,
                      itemBuilder: (context, index) {
                        final v = vocabs[index];
                        return _buildVocabCard(context, ref, v);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.indigo)),
              error: (err, stack) => Center(child: Text('Fehler: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddVocabularyScreen()),
        ),
        label: const Text('NEUES WORT', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildVocabCard(BuildContext context, WidgetRef ref, var v) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Dismissible(
        key: Key(v.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (_) => ref.read(isarServiceProvider).deleteVocabulary(v.id),
        child: ListTile(
          title: Text(v.english, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(v.german, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          trailing: Icon(Icons.chevron_right, color: Colors.indigo.shade100),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EditVocabularyScreen(vocabulary: v)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'Füge deine ersten Wörter hinzu!' : 'Keine Treffer gefunden.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}