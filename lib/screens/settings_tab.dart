import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../notifications/azkar_reminders.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ቆጠራዎችን አጽዳ?'),
        content: const Text('ሁሉም የዚክር ቆጠራዎችና የተስቢህ ቆጣሪ ወደ 0 ይመለሳሉ።'),
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
    if (ok == true) {
      state.resetAllCounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('ቅንብር')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const _Section('ግላዊ'),
          GoldCard(
            child: Row(
              children: [
                const _SettingIcon(icon: Icons.person_outline),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    initialValue: state.name,
                    onChanged: (value) =>
                        context.read<AppState>().setName(value),
                    decoration: const InputDecoration(
                      labelText: 'የተጠቃሚ ስም',
                      hintText: 'ስምህን ጻፍ',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Section('ማሳያ'),
          GoldCard(
            child: Column(
              children: [
                _SliderRow(
                  label: 'የትርጉምና የአነባበብ መጠን',
                  value: state.fontScale,
                  onChanged: (v) => context.read<AppState>().setFontScale(v),
                ),
                const SizedBox(height: 6),
                _SliderRow(
                  label: 'የአረብኛ መጠን',
                  value: state.arabicScale,
                  onChanged: (v) => context.read<AppState>().setArabicScale(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GoldCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SwitchRow(
                  title: 'የአነባበብ ጽሑፍ አሳይ',
                  subtitle: 'አረብኛው በአማርኛ ፊደል',
                  value: state.showTranslit,
                  onChanged: (v) => context.read<AppState>().setShowTranslit(v),
                ),
                Divider(height: 1, color: AppColors.border),
                _SwitchRow(
                  title: 'የአማርኛ ትርጉም አሳይ',
                  value: state.showAmharic,
                  onChanged: (v) => context.read<AppState>().setShowAmharic(v),
                ),
                Divider(height: 1, color: AppColors.border),
                _SwitchRow(
                  title: 'የንዝረት ምልክት',
                  subtitle: 'ሲቆጥሩ ትንሽ ይንዘፈዘፋል',
                  value: state.hapticOn,
                  onChanged: (v) => context.read<AppState>().setHapticOn(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Section('ገጽታ (Theme)'),
          const _ThemePicker(),
          const SizedBox(height: 18),
          const _Section('ማስታወሻ'),
          const _AzkarReminderCard(),
          const SizedBox(height: 18),
          const _Section('ውሂብ'),
          GoldCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const _SettingIcon(icon: Icons.restart_alt),
              title: Text(
                'ቆጠራዎችን አጽዳ',
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'የዚክር ቆጠራና የተስቢህ ቆጣሪ ወደ 0',
                style: TextStyle(color: AppColors.muted),
              ),
              onTap: () => _confirmReset(context),
            ),
          ),
          const SizedBox(height: 18),
          const _Section('ስለ መተግበሪያው'),
          GoldCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: _SettingIcon(icon: Icons.info_outline),
              title: Text(
                'እስላማዊ አዝካር',
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'ቅጽ 1.2.1 (Version 1.2.1)',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Amharic names for the five palettes, in the same order as [azkarPalettes].
const List<String> _paletteLabels = [
  'ብርሃናማ (Sacred Light)',
  'ሌሊታማ ኦቶማን (Midnight Ottoman)',
  'ብርጭቆ 3D (Glass 3D)',
  'መስጊድ (Masjid)',
  'ጨለማ ኤመራልድ (Dark Emerald)',
];

/// Lets the user pick one of the five colour themes. The choice is saved.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final selected = state.themeIndex;

    return GoldCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < azkarPalettes.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.border),
            InkWell(
              onTap: () => context.read<AppState>().setTheme(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _Swatch(palette: azkarPalettes[i]),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _paletteLabels[i],
                        style: TextStyle(
                          color: i == selected ? AppColors.gold : AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      i == selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: i == selected ? AppColors.gold : AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small preview of a palette: background, card and accent colours.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.palette});

  final AzkarPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(child: Container(color: palette.card)),
          Expanded(child: Container(color: palette.gold)),
          Expanded(child: Container(color: palette.accent)),
        ],
      ),
    );
  }
}

/// Small heading above each group of settings.
class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textSoft,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
        Slider(
          min: 0.8,
          max: 1.6,
          divisions: 8,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(title, style: TextStyle(color: AppColors.text)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: TextStyle(color: AppColors.muted)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.goldSoft),
        color: AppColors.bg,
      ),
      child: Icon(icon, color: AppColors.gold),
    );
  }
}


class _AzkarReminderCard extends StatefulWidget {
  const _AzkarReminderCard();
  @override
  State<_AzkarReminderCard> createState() => _AzkarReminderCardState();
}

class _AzkarReminderCardState extends State<_AzkarReminderCard> {
  static const _kOn = 'reminder_on';
  static const _kMorning = 'reminder_morning';
  static const _kEvening = 'reminder_evening';
  static const _kMode = 'reminder_mode';

  bool _enabled = false;
  ReminderMode _mode = ReminderMode.alarm;
  TimeOfDay _morning = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _evening = const TimeOfDay(hour: 18, minute: 0);
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reads the saved reminder settings so the card shows what is really set.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool(_kOn) ?? false;
      _morning = _fromMinutes(prefs.getInt(_kMorning) ?? 6 * 60);
      _evening = _fromMinutes(prefs.getInt(_kEvening) ?? 18 * 60);
      _mode = ReminderMode.fromStorage(prefs.getString(_kMode));
      _ready = true;
    });
  }

  static TimeOfDay _fromMinutes(int m) => TimeOfDay(hour: m ~/ 60, minute: m % 60);
  static int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Saves the settings and rebuilds the reminders. Returns false if the
  /// reminders could not be turned on (permission refused or an error).
  Future<bool> _apply({
    required bool enabled,
    required ReminderMode mode,
    required TimeOfDay morning,
    required TimeOfDay evening,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (enabled) {
        final granted = await AzkarReminders.instance.requestPermission();
        if (granted != true) {
          messenger.showSnackBar(const SnackBar(
            content: Text('ማሳወቂያ እንዲታይ ፍቃድ መስጠት አለብዎት።'),
          ));
          return false;
        }
      }
      await AzkarReminders.instance.configure(
        enabled: enabled,
        mode: mode,
        morningHour: morning.hour, morningMinute: morning.minute,
        eveningHour: evening.hour, eveningMinute: evening.minute,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOn, enabled);
      await prefs.setInt(_kMorning, _toMinutes(morning));
      await prefs.setInt(_kEvening, _toMinutes(evening));
      await prefs.setString(_kMode, mode.storageValue);
      if (enabled) {
        messenger.showSnackBar(const SnackBar(
          content: Text('የጠዋትና የማታ ማስታወሻ ተቀናብሯል።'),
        ));
      }
      return true;
    } catch (e) {
      // Shows the real error so it can be reported and fixed.
      messenger.showSnackBar(SnackBar(
        duration: const Duration(seconds: 10),
        content: Text('ማስታወሻውን ማቀናበር አልተቻለም። ($e)'),
      ));
      return false;
    }
  }

  Future<void> _setEnabled(bool value) async {
    final ok = await _apply(enabled: value, mode: _mode, morning: _morning, evening: _evening);
    if (ok && mounted) setState(() => _enabled = value);
  }

  Future<void> _setMode(ReminderMode mode) async {
    final ok = await _apply(enabled: _enabled, mode: mode, morning: _morning, evening: _evening);
    if (ok && mounted) setState(() => _mode = mode);
  }

  Future<void> _pick(bool morning) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: morning ? _morning : _evening,
      helpText: morning ? 'የጠዋት አዝካር ሰዓት' : 'የማታ አዝካር ሰዓት',
    );
    if (picked == null || !mounted) return;
    final newMorning = morning ? picked : _morning;
    final newEvening = morning ? _evening : picked;
    final ok = await _apply(enabled: _enabled, mode: _mode, morning: newMorning, evening: newEvening);
    if (ok && mounted) {
      setState(() {
        _morning = newMorning;
        _evening = newEvening;
      });
    }
  }

  String _format(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => GoldCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _SettingIcon(icon: Icons.notifications_active_outlined), SizedBox(width: 12),
        Expanded(child: Text('የጠዋትና የማታ ማስታወሻ', style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 8),
      Text('“አዝካር ማለትዎን አይርሱ” የሚል ዕለታዊ ማሳሰቢያ።', style: TextStyle(color: AppColors.muted)),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('ማስታወሻዎችን አብራ'),
        value: _enabled,
        onChanged: _ready ? (v) => _setEnabled(v) : null,
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: SegmentedButton<ReminderMode>(
            segments: const [
              ButtonSegment(value: ReminderMode.alarm, icon: Icon(Icons.alarm), label: Text('አላርም')),
              ButtonSegment(value: ReminderMode.notification, icon: Icon(Icons.notifications_none), label: Text('ማሳወቂያ')),
            ],
            selected: {_mode},
            onSelectionChanged: _ready && _enabled ? (s) => _setMode(s.first) : null,
          ),
        ),
      ),
      ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.wb_sunny_outlined, color: AppColors.gold), title: const Text('የጠዋት አዝካር'), trailing: Text(_format(_morning), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)), onTap: () => _pick(true)),
      ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.nightlight_outlined, color: AppColors.gold), title: const Text('የማታ አዝካር'), trailing: Text(_format(_evening), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)), onTap: () => _pick(false)),
      const SizedBox(height: 4),
      Text('መደበኛ ሰዓት፦ ጠዋት 06:00፣ ማታ 18:00 (የኢትዮጵያ ሰዓት። ሊቀየር ይችላል።)', style: TextStyle(fontSize: 11, color: AppColors.muted)),
    ]),
  );
}
