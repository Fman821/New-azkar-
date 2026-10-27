import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// Tasbih counter on its own page: a glowing ring fills up to the chosen goal,
/// with a light vibration on every count.
class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  // 0 means no goal: the counter just goes up.
  static const _targets = [33, 99, 100, 0];

  Future<void> _confirmReset(BuildContext context) async {
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ተስቢህን አጽዳ?'),
        content: const Text('ቆጠራው ወደ 0 ይመለሳል።'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('አይ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('አዎ'),
          ),
        ],
      ),
    );
    if (ok == true) state.resetTasbih();
  }

  void _tap(BuildContext context) {
    final state = context.read<AppState>();
    final before = state.tasbih;
    state.tapTasbih();
    if (!state.hapticOn) return;
    final target = state.tasbihTarget;
    final completedRound = target > 0 && (before + 1) % target == 0;
    if (completedRound) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final target = state.tasbihTarget;
    final count = state.tasbih;
    final rounds = target > 0 ? count ~/ target : 0;
    final inRound = target > 0 ? count % target : count;
    final progress = target > 0 ? inRound / target : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ተስቢህ መቁጠሪያ'),
        actions: [
          IconButton(
            tooltip: 'አጽዳ',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: [
                for (final t in _targets)
                  ChoiceChip(
                    label: Text(
                      t == 0 ? 'ያለ ገደብ' : '$t',
                      style: TextStyle(
                        color: target == t ? AppColors.bg : AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: target == t,
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.card,
                    side: BorderSide(color: AppColors.goldSoft.withAlpha(90)),
                    showCheckmark: false,
                    onSelected: (_) => state.setTasbihTarget(t),
                  ),
              ],
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _tap(context),
                  child: Container(
                    width: 310,
                    height: 310,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.gold.withAlpha(55), Colors.transparent],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 286,
                          height: 286,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 14,
                            strokeCap: StrokeCap.round,
                            backgroundColor: AppColors.border,
                            color: AppColors.gold,
                          ),
                        ),
                        Container(
                          width: 226,
                          height: 226,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppColors.tile([const Color(0xFF137A63), AppColors.cardDeep]),
                            ),
                            border: Border.all(color: AppColors.goldSoft.withAlpha(160), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ተስቢህ',
                                style: TextStyle(color: AppColors.muted, fontSize: 13, letterSpacing: 1),
                              ),
                              Text(
                                '$inRound',
                                style: TextStyle(
                                  fontSize: 76,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gold,
                                  height: 1.05,
                                ),
                              ),
                              Text(
                                target > 0 ? 'ከ $target' : 'ጠቅላላ $count',
                                style: TextStyle(color: AppColors.textSoft, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
              child: Row(
                children: [
                  Expanded(child: _Stat(label: 'ጠቅላላ', value: '$count')),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat(label: 'ዙሮች', value: '$rounds')),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text('ክቡን ነክተው ይቁጠሩ', style: TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldSoft.withAlpha(110)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
