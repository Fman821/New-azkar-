import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../audio/azkar_player.dart';
import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/dhikr_card.dart';

/// All items in one azkar category (morning, evening, house, ...).
class AzkarListScreen extends StatelessWidget {
  const AzkarListScreen({super.key, required this.category});

  final AzkarCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        actions: [
          IconButton(
            tooltip: 'ቆጠራዎችን አጽዳ',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => context.read<AppState>().resetCategory(category.id),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: category.items.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Text(
                    category.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                  if (category.id == 'morning' || category.id == 'evening') ...[
                    const SizedBox(height: 12),
                    _FullRecitationCard(
                      categoryId: category.id,
                      title: category.id == 'morning'
                          ? 'ሙሉ የጠዋት አዝካር ድምፅ'
                          : 'ሙሉ የምሽት አዝካር ድምፅ',
                      asset: category.id == 'morning'
                          ? 'assets/audio/morning_adhkar.mp3'
                          : 'assets/audio/evening_adhkar.mp3',
                    ),
                  ],
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DhikrCard(dhikr: category.items[i - 1], index: i),
          );
        },
      ),
    );
  }
}


class _FullRecitationCard extends StatelessWidget {
  const _FullRecitationCard({
    required this.categoryId,
    required this.title,
    required this.asset,
  });

  final String categoryId;
  final String title;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AzkarPlayer>();
    final key = 'full-recitation:$categoryId';
    final playing = player.isPlaying(key);
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.gold),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(Icons.headphones, color: AppColors.gold, size: 30),
        title: Text(title, style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        subtitle: Text('ከኢንተርኔት ውጭም ማዳመጥ ይቻላል', style: TextStyle(color: AppColors.textSoft)),
        trailing: IconButton(
          tooltip: playing ? 'አቁም' : 'አዳምጥ',
          icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppColors.gold, size: 36),
          onPressed: () async {
            final error = await context.read<AzkarPlayer>().toggle(key, asset);
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
            }
          },
        ),
      ),
    );
  }
}
