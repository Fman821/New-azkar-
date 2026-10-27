import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../theme.dart';
import '../widgets/dhikr_card.dart';

/// Searches every azkar item and dua by title, Arabic text or Amharic meaning.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  Timer? _debounce;

  /// Waits until the user stops typing for 300 ms before filtering.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = context.read<Content>();
    final everything = [...content.allAzkar, ...content.duas];

    final q = _query.trim();
    final arabicQuery = normalizeArabic(q);
    final results = q.isEmpty
        ? const <Dhikr>[]
        : everything
            .where(
              (d) =>
                  d.title.contains(q) ||
                  d.amharic.contains(q) ||
                  (arabicQuery.isNotEmpty &&
                      normalizeArabic(d.arabic).contains(arabicQuery)),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ፈልግ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: _onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'በአዝካሮች ውስጥ ፈልግ...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: q.isEmpty
                ? Center(
                    child: Text(
                      'ቃል ጻፍ',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : results.isEmpty
                    ? Center(
                        child: Text(
                          'ምንም አልተገኘም',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: results.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: DhikrCard(dhikr: results[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
