import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'azkar_list_screen.dart';
import 'names_screen.dart';
import 'tasbih_screen.dart';

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

  static List<Color> get _morningGradient => switch (AppColors.themeIndex) {
        0 => const [Color(0xFFE8F4EC), Color(0xFFF9F6F0)],
        1 => const [Color(0xFF25385F), Color(0xFF0A1128)],
        2 => const [Color(0xFF176653), Color(0xFF0A3028)],
        3 => const [Color(0xFFE8F3E9), Color(0xFFDDEBDD)],
        _ => const [Color(0xFF137A63), Color(0xFF063A2F)],
      };

  static List<Color> get _eveningGradient => switch (AppColors.themeIndex) {
        0 => const [Color(0xFFF8EBD6), Color(0xFFFFFCF7)],
        1 => const [Color(0xFF45354D), Color(0xFF10172E)],
        2 => const [Color(0xFF15566A), Color(0xFF0A302D)],
        3 => const [Color(0xFFE2EDE9), Color(0xFFF7F4E9)],
        _ => const [Color(0xFF0D5A6E), Color(0xFF062A36)],
      };

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

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.isDark
                    ? [AppColors.bg, Color.lerp(AppColors.bg, AppColors.accent, 0.10)!]
                    : [AppColors.bg, Color.lerp(AppColors.bg, AppColors.goldSoft, 0.12)!],
              ),
            ),
            child: CustomPaint(painter: _IslamicPatternPainter()),
          ),
        ),
        SafeArea(
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
                  colors: _morningGradient,
                  onTap: () => openCategory(context, morning),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PeriodCard(
                  category: evening,
                  icon: Icons.nights_stay_outlined,
                  colors: _eveningGradient,
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
          const SizedBox(height: 16),
          _TasbihShortcut(
            count: state.tasbih,
            target: state.tasbihTarget,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TasbihScreen()),
            ),
          ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Subtle, low-contrast geometric ornament that gives the background a
/// calm Islamic pattern without reducing text readability.
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (AppColors.isDark ? AppColors.gold : AppColors.goldDark)
          .withAlpha(AppColors.isDark ? 13 : 18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    const gap = 58.0;
    for (double y = 18; y < size.height + gap; y += gap) {
      for (double x = 8; x < size.width + gap; x += gap) {
        final path = Path()
          ..moveTo(x, y - 12)
          ..lineTo(x + 12, y)
          ..lineTo(x, y + 12)
          ..lineTo(x - 12, y)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(x, y), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) => false;
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

  static List<Color> get _verseGradient => switch (AppColors.themeIndex) {
        0 => const [Color(0xFFFFFFFF), Color(0xFFF3ECD9)],
        1 => const [Color(0xFF18284B), Color(0xFF0A1128)],
        2 => const [Color(0xFF176653), Color(0xFF0A3028)],
        3 => const [Color(0xFFFFFFFF), Color(0xFFEAF2E7)],
        _ => const [Color(0xFF0E7A62), Color(0xFF063B31)],
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.tile(_verseGradient),
        ),
        border: Border.all(color: AppColors.gold.withAlpha(140)),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDark
                ? Colors.black.withAlpha(65)
                : AppColors.goldDark.withAlpha(24),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.gold.withAlpha(AppColors.isDark ? 18 : 20),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: AppColors.gold),
              const SizedBox(width: 7),
              Text(
                'የዛሬ የቁርአን አንቀጽ',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
        height: 174,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.tile(colors),
          ),
          border: Border.all(color: AppColors.goldSoft.withAlpha(150)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.isDark ? Colors.black.withAlpha(45) : AppColors.goldDark.withAlpha(24),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
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

/// A compact, tappable tasbih shortcut that leaves the reserved tile untouched.
class _TasbihShortcut extends StatelessWidget {
  const _TasbihShortcut({
    required this.count,
    required this.target,
    required this.onTap,
  });

  final int count;
  final int target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (count / target).clamp(0.0, 1.0).toDouble() : 0.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.gold.withAlpha(130)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withAlpha(AppColors.isDark ? 22 : 12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withAlpha(24),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: Icon(Icons.fingerprint, color: AppColors.gold, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ተስቢህ መቁጠሪያ',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      target > 0 ? '$count / $target' : '$count ዚክሮች',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppColors.gold.withAlpha(35),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reserved home-screen tile for a future feature.
class _SoonCard extends StatelessWidget {
  const _SoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 174,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.card.withAlpha(AppColors.isDark ? 230 : 245),
        border: Border.all(color: AppColors.goldSoft.withAlpha(110)),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDark ? Colors.black.withAlpha(35) : AppColors.goldDark.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GoldBadge(icon: Icons.auto_awesome, size: 46),
          const Spacer(),
          Text(
            'ቦታ ተይዟል',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coming soon',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Icon(Icons.more_horiz, color: AppColors.goldSoft),
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
        height: 174,
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
