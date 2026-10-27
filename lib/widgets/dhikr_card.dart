import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../audio/azkar_player.dart';
import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';

/// One dhikr: number, Arabic text, Amharic meaning, source, play button (when
/// there is a recording), favourite button and a counter that counts up to
/// the required repeat.
class DhikrCard extends StatelessWidget {
  const DhikrCard({super.key, required this.dhikr, this.index});

  final Dhikr dhikr;
  final int? index;

  Future<void> _togglePlay(BuildContext context) async {
    final player = context.read<AzkarPlayer>();
    final error = await player.toggle(dhikr.key, dhikr.audio);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  /// Shares the dhikr text (Arabic, Amharic meaning, source) through any app.
  void _share() {
    final buffer = StringBuffer();
    buffer.writeln(dhikr.title);
    buffer.writeln();
    buffer.writeln(dhikr.arabic);
    buffer.writeln();
    if (dhikr.translit.isNotEmpty) {
      buffer.writeln('አነባበብ: ${dhikr.translit}');
    }
    buffer.writeln('ትርጉም: ${dhikr.amharic}');
    if (dhikr.source.isNotEmpty) {
      buffer.writeln('ምንጭ: ${dhikr.source}');
    }
    buffer.writeln();
    buffer.write('— እስላማዊ አዝካር');
    Share.share(buffer.toString(), subject: dhikr.title);
  }

  void _tap(BuildContext context) {
    final state = context.read<AppState>();
    state.tapDhikr(dhikr.key, dhikr.repeat);
    if (state.hapticOn) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final player = context.watch<AzkarPlayer>();
    final scale = state.fontScale;
    final isFavorite = state.isFavorite(dhikr.key);
    final count = state.progressOf(dhikr.key);
    final done = count >= dhikr.repeat;
    final double progress = done ? 1.0 : count / dhikr.repeat;
    final isPlaying = player.isPlaying(dhikr.key);

    return GoldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (index != null) ...[
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.goldDark,
                  child: Text(
                    '$index',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  dhikr.title,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
              if (dhikr.audio.isNotEmpty)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: isPlaying ? 'አቁም' : 'አዳምጥ',
                  onPressed: () => _togglePlay(context),
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: AppColors.gold,
                    size: 28,
                  ),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'አጋራ',
                onPressed: _share,
                icon: Icon(Icons.share_outlined, color: AppColors.gold),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: isFavorite ? 'ከተወዳጆች አውጣ' : 'ወደ ተወዳጆች ጨምር',
                onPressed: () =>
                    context.read<AppState>().toggleFavorite(dhikr.key),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              dhikr.arabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quran',
                fontSize: 24 * scale * state.arabicScale,
                height: 2.0,
                color: AppColors.text,
              ),
            ),
          ),
          Divider(color: AppColors.border, height: 24),
          if (state.showTranslit && dhikr.translit.isNotEmpty) ...[
            Text(
              dhikr.translit,
              style: TextStyle(
                fontSize: 15 * scale,
                height: 1.7,
                color: AppColors.goldSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (state.showAmharic) Text(
            dhikr.amharic,
            style: TextStyle(
              fontSize: 15 * scale,
              height: 1.7,
              color: AppColors.textSoft,
            ),
          ),
          if (dhikr.source.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ምንጭ: ${dhikr.source}',
              style: TextStyle(fontSize: 12 * scale, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: done
                    ? null
                    : () => _tap(context),
                child: Text(
                  done ? 'ተጠናቋል ✓' : '+1  ($count/${dhikr.repeat})',
                ),
              ),
              if (count > 0)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'ዳግም አስጀምር',
                  onPressed: () =>
                      context.read<AppState>().resetDhikr(dhikr.key),
                  icon: Icon(Icons.refresh, color: AppColors.muted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
