import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home_tab.dart';
import 'names_screen.dart';

/// The "ጸሎት" tab: the 99 names and the list of duas, each with its own page.
class DuasTab extends StatelessWidget {
  const DuasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final content = context.read<Content>();
    final duas = AzkarCategory(
      id: 'duas',
      title: 'ዱዓዎች',
      subtitle: 'ከቁርኣንና ከሐዲስ የተወሰዱ ዱዓዎች',
      icon: 'hand',
      image: 'bg_duas.jpg',
      items: content.duas,
    );
    final doneCount =
        duas.items.where((d) => state.progressOf(d.key) >= d.repeat).length;

    return Scaffold(
      appBar: AppBar(title: const Text('ዱዓ እና ዚክር')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          _NamesHero(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NamesScreen()),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ዝርዝሮች',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _ListCard(
            icon: iconFor(duas.icon),
            title: duas.title,
            subtitle: '${duas.items.length} ዱዓዎች · $doneCount ተጠናቋል',
            onTap: () => openCategory(context, duas),
          ),
        ],
      ),
    );
  }
}

class _NamesHero extends StatelessWidget {
  const _NamesHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.tile(const [Color(0xFF137A63), Color(0xFF052A22)]),
          ),
          border: Border.all(color: AppColors.gold.withAlpha(150)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '99 የአላህ ስሞች',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'አስማኡል ሁስና: ስሞችን ለማንበብና ትርጉማቸውን ለማወቅ',
                          style: TextStyle(color: AppColors.textSoft, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          'ይክፈቱ ›',
                          style: TextStyle(color: AppColors.gold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const GoldBadge(icon: Icons.auto_awesome_outlined, size: 64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.tile(const [Color(0xFF0E5C4B), Color(0xFF062A21)]),
            ),
            border: Border.all(color: AppColors.goldSoft.withAlpha(120)),
          ),
          child: Row(
            children: [
              GoldBadge(icon: icon, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: AppColors.textSoft, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
