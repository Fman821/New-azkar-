import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'azkar_list_screen.dart';
import 'names_screen.dart';

class _Ayah {
  const _Ayah(this.arabic, this.amharic, this.reference);

  final String arabic;
  final String amharic;
  final String reference;
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onOpenTab});

  /// Switches the bottom navigation to the tab at [index].
  final void Function(int index) onOpenTab;

  static const _ayat = <_Ayah>[
    _Ayah(
      'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'አስታውሱ! ልቦች የሚረጋጉት በአላህ ማስታወስ ብቻ ነው።',
      'ሱረቱ አር-ረዕድ (13:28)',
    ),
    _Ayah(
      'فَاذْكُرُونِي أَذْكُرْكُمْ',
      'እኔን አስታውሱ፤ እኔም አስታውሳችኋለሁ።',
      'ሱረቱል በቀራ (2:152)',
    ),
    _Ayah(
      'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'ከችግር ጋር ምቾት አለና።',
      'ሱረቱ አሽ-ሸርሕ (94:6)',
    ),
    _Ayah(
      'وَمَنْ يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'በአላህ የሚመካ ሰው እርሱ ይበቃዋል።',
      'ሱረቱ ጦላቅ (65:3)',
    ),
    _Ayah(
      'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'ጌታችን ሆይ! በዱንያ መልካምን ስጠን፤ በአኼራም መልካምን ስጠን፤ ከእሳት ቅጣትም ጠብቀን።',
      'ሱረቱል በቀራ (2:201)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final content = context.read<Content>();
    final morning = content.categoryById('morning')!;
    final evening = content.categoryById('evening')!;

    // A different verse each day.
    final dayIndex = DateTime.now().difference(DateTime(2024)).inDays;
    final ayah = _ayat[dayIndex % _ayat.length];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          _Greeting(name: state.name),
          const SizedBox(height: 18),
          _VerseCard(
            ayah: ayah,
            fontScale: state.fontScale,
            arabicScale: state.arabicScale,
          ),
          const SizedBox(height: 24),
          const _SectionTitle('ዕለታዊ ዚክሮች'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PeriodCard(
                  category: morning,
                  icon: Icons.wb_twilight,
                  colors: const [Color(0xFF137A63), Color(0xFF063A2F)],
                  onTap: () => openCategory(context, morning),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PeriodCard(
                  category: evening,
                  icon: Icons.nights_stay_outlined,
                  colors: const [Color(0xFF0D5A6E), Color(0xFF062A36)],
                  onTap: () => openCategory(context, evening),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle('በቅርብ'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NamesCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const NamesScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: _SoonCard()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Opens an azkar category's list of items.
void openCategory(BuildContext context, AzkarCategory category) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AzkarListScreen(category: category),
    ),
  );
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'ሰላም' : 'ሰላም አለይኩም፣ $name',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'እስላማዊ አዝካር',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const GoldBadge(icon: Icons.brightness_high, size: 58),
      ],
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.ayah,
    required this.fontScale,
    required this.arabicScale,
  });

  final _Ayah ayah;
  final double fontScale;
  final double arabicScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.tile(const [Color(0xFF0E7A62), Color(0xFF063B31)]),
        ),
        border: Border.all(color: AppColors.gold.withAlpha(140)),
        boxShadow: const [
          BoxShadow(color: Color(0x80000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text(
            ayah.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Quran',
              fontSize: 22 * fontScale * arabicScale,
              height: 1.9,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ayah.amharic,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * fontScale,
              height: 1.6,
              color: AppColors.textSoft,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ayah.reference,
              style: TextStyle(fontSize: 12, color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSoft,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.category,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final AzkarCategory category;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.tile(colors),
          ),
          border: Border.all(color: AppColors.goldSoft.withAlpha(150)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoldBadge(icon: icon, size: 46),
                  const Spacer(),
                  Text(
                    category.title,
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${category.items.length} አዝካሮች ›',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
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

/// Placeholder for a section that is not ready yet.
class _SoonCard extends StatelessWidget {
  const _SoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDeep.withAlpha(180),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_clock_outlined, color: AppColors.muted, size: 34),
          const Spacer(),
          Text(
            'ቦታ ተይዟል',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Coming soon',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// The 99 names of Allah, shown in the first slot of the "በቅርብ" row.
class _NamesCard extends StatelessWidget {
  const _NamesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.tile(const [Color(0xFF137A63), Color(0xFF052A22)]),
          ),
          border: Border.all(color: AppColors.goldSoft.withAlpha(150)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GoldBadge(icon: Icons.auto_awesome_outlined, size: 46),
                  const Spacer(),
                  Text(
                    '99 የአላህ ስሞች',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'አስማኡል ሁስና',
                    style: TextStyle(color: AppColors.textSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ይክፈቱ ›',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
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
