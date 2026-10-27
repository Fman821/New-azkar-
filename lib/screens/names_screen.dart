import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// The 99 names of Allah, with search by name, meaning or number.
class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
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
    final scale = context.watch<AppState>().fontScale;
    final names = context.read<Content>().names;

    final q = _query.trim();
    final lower = q.toLowerCase();
    final arabicQuery = normalizeArabic(q);
    final visible = q.isEmpty
        ? names
        : names
            .where(
              (n) =>
                  n.transliteration.toLowerCase().contains(lower) ||
                  n.meaning.contains(q) ||
                  (arabicQuery.isNotEmpty &&
                      normalizeArabic(n.arabic).contains(arabicQuery)) ||
                  n.number.toString() == q,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('99 የአላህ ስሞች')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: _onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'ስም ፈልግ (Search)',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      'ምንም አልተገኘም',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final n = visible[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GoldCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.goldSoft),
                                ),
                                child: Text(
                                  '${n.number}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.transliteration,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      n.meaning,
                                      style: TextStyle(
                                        fontSize: 13 * scale,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                flex: 2,
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    n.arabic,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontFamily: 'Quran',
                                      fontSize: 22 * scale,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
