import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/dhikr_card.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final content = context.read<Content>();
    final items = [...content.allAzkar, ...content.duas]
        .where((d) => state.isFavorite(d.key))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ተወዳጆች')),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'ገና ተወዳጅ የለም። ከአዝካሮች ወይም ከጸሎቶች ላይ ልብን ይጫኑ።',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DhikrCard(dhikr: items[i]),
              ),
            ),
    );
  }
}
