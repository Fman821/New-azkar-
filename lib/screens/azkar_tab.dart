import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home_tab.dart';
import 'search_screen.dart';
import 'tasbih_screen.dart';

/// The "አዝካር" tab: the tasbih entry, then every category grouped and shown
/// as colourful tiles with how much of each one is done.
class AzkarTab extends StatelessWidget {
  const AzkarTab({super.key});

  static const _groups = <String, List<String>>{
    'ዕለታዊ ዚክሮች': ['morning', 'noon', 'evening'],
    'ቤትና ጉዞ': ['house', 'travel'],
    'ሌሎች': ['other'],
  };

  static const _palette = <String, List<Color>>{
    'morning': [Color(0xFF137A63), Color(0xFF063B31)],
    'noon': [Color(0xFF8A6A1E), Color(0xFF3A2A08)],
    'evening': [Color(0xFF0D5A6E), Color(0xFF062A36)],
    'house': [Color(0xFF1D6B45), Color(0xFF0A2E1D)],
    'travel': [Color(0xFF0F6470), Color(0xFF07303A)],
    'other': [Color(0xFF6B4E12), Color(0xFF2A1E07)],
  };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final byId = {for (final c in context.read<Content>().categories) c.id: c};

    int doneOf(AzkarCategory c) =>
        c.items.where((d) => state.progressOf(d.key) >= d.repeat).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('አዝካሮች'),
        actions: [
          IconButton(
            tooltip: 'ፈልግ',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _TasbihEntry(
            count: state.tasbih,
            target: state.tasbihTarget,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TasbihScreen()),
            ),
          ),
          for (final group in _groups.entries) ...[
            const SizedBox(height: 24),
            _GroupTitle(group.key),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                for (final id in group.value)
                  if (byId[id] != null)
                    _CategoryTile(
                      category: byId[id]!,
                      colors: _palette[id]!,
                      done: doneOf(byId[id]!),
                      onTap: () => openCategory(context, byId[id]!),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TasbihEntry extends StatelessWidget {
  const _TasbihEntry({required this.count, required this.target, required this.onTap});

  final int count;
  final int target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final goal = target == 0 ? 'ያለ ገደብ' : 'ዒላማ $target';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB8860B), Color(0xFF5A4206)],
            ),
            border: Border.all(color: AppColors.gold.withAlpha(170)),
            boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(35), blurRadius: 18)],
          ),
          child: Row(
            children: [
              const GoldBadge(icon: Icons.adjust, size: 54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ተስቢህ መቁጠሪያ',
                      style: TextStyle(color: Color(0xFFFFF3C4), fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$count ቆጠራ · $goal',
                      style: const TextStyle(color: Color(0xFFFFE7A3), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFFFF3C4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: AppColors.textSoft,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.colors,
    required this.done,
    required this.onTap,
  });

  final AzkarCategory category;
  final List<Color> colors;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = category.items.length;
    final progress = total == 0 ? 0.0 : done / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.tile(colors),
          ),
          border: Border.all(color: AppColors.goldSoft.withAlpha(130)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoldBadge(icon: iconFor(category.icon), size: 46),
                  const Spacer(),
                  Text(
                    category.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.black.withAlpha(90),
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$done / $total',
                    style: TextStyle(color: AppColors.textSoft, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
