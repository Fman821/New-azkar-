import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Maps the icon names used in azkar.json to Material icons.
IconData iconFor(String name) {
  switch (name) {
    case 'sun':
      return Icons.wb_sunny_outlined;
    case 'clock':
      return Icons.schedule;
    case 'moon':
      return Icons.nights_stay_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'plane':
      return Icons.flight_outlined;
    case 'list':
      return Icons.format_list_bulleted;
    case 'names':
      return Icons.auto_awesome_outlined;
    case 'hand':
      return Icons.front_hand_outlined;
    default:
      return Icons.menu_book_outlined;
  }
}

/// Dark green card with a gold border, used for every content block.
class GoldCard extends StatelessWidget {
  const GoldCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.tile([const Color(0xFF0F3B29), AppColors.cardDeep]),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldSoft.withAlpha(150)),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      // A transparent Material gives ListTile, IconButton and TextField the
      // Material ancestor they need, without painting anything extra.
      child: Material(
        type: MaterialType.transparency,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Gold diamond with an icon in it, like the badges on the mockup tiles.
class GoldBadge extends StatelessWidget {
  const GoldBadge({super.key, required this.icon, this.size = 46});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final diamond = size * 0.72;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: diamond,
              height: diamond,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.tile([const Color(0xFF0F3B29), AppColors.cardDeep]),
                ),
                borderRadius: BorderRadius.circular(size * 0.1),
                border: Border.all(color: AppColors.gold, width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.gold.withAlpha(70), blurRadius: 10),
                ],
              ),
            ),
          ),
          Icon(icon, color: AppColors.gold, size: size * 0.42),
        ],
      ),
    );
  }
}

/// Round gold button with an arrow, shown at the bottom right of a tile.
class GoldRoundButton extends StatelessWidget {
  const GoldRoundButton({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3CF5A), Color(0xFFB98A14)],
        ),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF2A1D00)),
    );
  }
}

/// A tile with a background photo, a dark gradient on top, a gold badge at
/// the top-left and [child] at the bottom.
class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.image,
    required this.height,
    required this.child,
    this.onTap,
    this.icon,
  });

  final String image;
  final double height;
  final Widget child;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.goldSoft.withAlpha(160)),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/$image', fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.bg.withAlpha(60),
                      AppColors.card.withAlpha(235),
                    ],
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: radius,
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(alignment: Alignment.bottomLeft, child: child),
                  ),
                ),
              ),
              if (icon != null)
                Positioned(
                  top: 10,
                  left: 10,
                  // Let taps pass through the badge to the tile below it.
                  child: IgnorePointer(child: GoldBadge(icon: icon!)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title, subtitle, optional item count pill, and the gold arrow button.
class TileBody extends StatelessWidget {
  const TileBody({
    super.key,
    required this.title,
    required this.subtitle,
    this.count,
  });

  final String title;
  final String subtitle;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSoft),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.goldSoft),
                  color: AppColors.gold.withAlpha(25),
                ),
                child: Text(
                  '$count አዝካሮች',
                  style: TextStyle(color: AppColors.gold, fontSize: 12),
                ),
              ),
            const Spacer(),
            const GoldRoundButton(icon: Icons.arrow_forward),
          ],
        ),
      ],
    );
  }
}
