import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/theme_provider.dart';
import '../models/vocabulary.dart';
import 'add_vocabulary_screen.dart';
import 'edit_vocabulary_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(filteredVocabularyProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final categories = ref.watch(categoryListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final themeMode = ref.watch(themeProvider);

    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color headerColor = theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10, 
                bottom: 25, 
                left: 20, 
                right: 20
              ),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35), 
                  bottomRight: Radius.circular(35)
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Text(
                        'VocApp', 
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                        icon: Icon(
                          themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Begriff suchen...',
                      prefixIcon: Icon(Icons.search, color: Colors.indigo),
                      fillColor: Colors.white, 
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = cat,
                            selectedColor: Colors.orangeAccent,
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.indigo.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.indigo),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            side: BorderSide.none, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: vocabAsync.when(
                data: (vocabs) => vocabs.isEmpty
                    ? Center(child: Text(searchQuery.isEmpty ? 'Liste ist leer.' : 'Kein Treffer.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vocabs.length,
                        itemBuilder: (context, index) {
                          final v = vocabs[index];
                          return _buildAnimatedVocabCard(context, ref, v, index);
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Fehler: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddVocabularyScreen())),
        label: const Text('NEUES WORT'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedVocabCard(BuildContext context, WidgetRef ref, Vocabulary v, int index) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 50)),
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 30),
          child: Opacity(opacity: 1.0 - value, child: child),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), 
          side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            v.english, 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                v.german, 
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  // KORREKTUR: withValues statt withOpacity
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  v.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? theme.colorScheme.primaryContainer : theme.colorScheme.primary
                  ),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.edit_note),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditVocabularyScreen(vocabulary: v))),
        ),
      ),
    );
  }
}