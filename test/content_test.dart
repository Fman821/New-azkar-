import 'dart:io';

import 'package:daily_azkar/models/content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Content content;

  setUpAll(() {
    content = ContentRepository.parse(
      azkarJson: File('assets/data/azkar.json').readAsStringSync(),
      namesJson: File('assets/data/names.json').readAsStringSync(),
      duasJson: File('assets/data/duas.json').readAsStringSync(),
    );
  });

  test('has all 99 names of Allah, each numbered once', () {
    expect(content.names.length, 99);
    expect(content.names.map((n) => n.number).toSet().length, 99);
    expect(content.names.first.transliteration, 'Ar-Rahman');
    expect(content.names.last.transliteration, 'As-Sabur');
  });

  test('has six azkar categories, each with items', () {
    expect(content.categories.map((c) => c.id).toList(),
        ['morning', 'noon', 'evening', 'house', 'travel', 'other']);
    for (final category in content.categories) {
      expect(category.items, isNotEmpty, reason: category.id);
    }
  });

  test('every dhikr has Arabic text, an Amharic meaning and a repeat count', () {
    final all = [...content.allAzkar, ...content.duas];
    for (final d in all) {
      expect(d.arabic.trim(), isNotEmpty, reason: d.key);
      expect(d.amharic.trim(), isNotEmpty, reason: d.key);
      expect(d.repeat, greaterThanOrEqualTo(1), reason: d.key);
    }
  });


  test('Arabic search normalization ignores vowel marks and common alef forms', () {
    expect(normalizeArabic('إِنَّ اللَّهَ'), normalizeArabic('ان الله'));
    expect(normalizeArabic('ٱلرَّحْمَٰن'), normalizeArabic('الرحمن'));
  });

  test('bundled audio files referenced as assets exist', () {
    final all = [...content.allAzkar, ...content.duas];
    for (final dhikr in all.where((d) => d.audio.startsWith('assets/'))) {
      expect(File(dhikr.audio).existsSync(), isTrue, reason: dhikr.key);
    }
    expect(File('assets/audio/morning_adhkar.mp3').existsSync(), isTrue);
    expect(File('assets/audio/evening_adhkar.mp3').existsSync(), isTrue);
  });

  test('dhikr keys are unique', () {
    final keys = [...content.allAzkar, ...content.duas].map((d) => d.key);
    expect(keys.toSet().length, keys.length);
  });
}
